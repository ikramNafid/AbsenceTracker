
import 'package:absence_tracker/models/absence_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('absence_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table roles
    await db.execute('''
      CREATE TABLE roles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Table users
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        roleId INTEGER NOT NULL,
        FOREIGN KEY(roleId) REFERENCES roles(id)
      )
    ''');

    // Table groups
    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        filiere TEXT NOT NULL
      )
    ''');

    // Table students
    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER,
        massar TEXT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        FOREIGN KEY(groupId) REFERENCES groups(id)
      )
    ''');

    // Table modules
    await db.execute('''
      CREATE TABLE modules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        semester TEXT,
        groupId INTEGER,
        FOREIGN KEY(groupId) REFERENCES groups(id)
      )
    ''');

    // Table sessions
    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moduleId INTEGER,
        date TEXT,
        time TEXT,
        type TEXT,
        FOREIGN KEY(moduleId) REFERENCES modules(id)
      )
    ''');

    // Table absences
    await db.execute('''
      CREATE TABLE absences(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        studentId INTEGER,
        status TEXT,
        FOREIGN KEY(sessionId) REFERENCES sessions(id),
        FOREIGN KEY(studentId) REFERENCES students(id)
      )
    ''');

    // INSERTION DES RÔLES
    await db.insert('roles', {'name': 'Etudiant'});
    await db.insert('roles', {'name': 'Professeur'});
    await db.insert('roles', {'name': 'Coordinateur'});
    await db.insert('roles', {'name': 'Admin'});

    // INSERTION DES UTILISATEURS PAR DÉFAUT
    await db.insert('users', {
      'firstName': 'Ikram',
      'lastName': 'Nafid',
      'email': 'ikram@ump.com',
      'password': '2003',
      'roleId': 1,
    });

    await db.insert('users', {
      'firstName': 'Mohammed',
      'lastName': 'Boudchiche',
      'email': 'mohammed@ump.com',
      'password': '1234',
      'roleId': 2,
    });

    await db.insert('users', {
      'firstName': 'Sofia',
      'lastName': 'Elhaj',
      'email': 'sofia@ump.com',
      'password': 'abcd',
      'roleId': 3,
    });

    await db.insert('users', {
      'firstName': 'Admin',
      'lastName': 'Admin',
      'email': 'admin@ump.com',
      'password': 'admin',
      'roleId': 4,
    });

    // insertion des tableau pour tester l'absence des etudiant
        // pour group
    final groupId = await db.insert('groups', {
      'id':1,
      'name': 'GI1',
      'filiere': 'Informatique',
});
// pour etudiant
    final studentId = await db.insert('students', {
      'id':1,
      'groupId': groupId,
      'massar': 'M123',
      'firstName': 'Maryam',
      'lastName': 'Lahyani',
      'email': 'maryam@ump.com',
    });
        // pour tableau module
    final moduleId = await db.insert('modules', {
      'id': 1,
      'name': 'Mobile',
      'semester': 'S7',
      'groupId': groupId,
});

    // pour tableau session
    final sessionId = await db.insert('sessions', {
      'id': 1,
      'moduleId': moduleId,
      'date': '2025-02-24',
      'time': '09:00',
      'type': 'TP',
});

    // pour tableau absence
    await db.insert('absences', {
      'id': 1,
      'sessionId': sessionId,
      'studentId': studentId,
      'status': 'absent',
});
    // fin
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS roles');
      await db.execute('DROP TABLE IF EXISTS students');
      await db.execute('DROP TABLE IF EXISTS groups');
      await db.execute('DROP TABLE IF EXISTS modules');
      await db.execute('DROP TABLE IF EXISTS sessions');
      await db.execute('DROP TABLE IF EXISTS absences');
      await _createDB(db, newVersion);
    }
  }

  // LOGIN avec rôle
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT u.id, u.firstName, u.lastName, u.email, u.roleId, r.name as roleName
      FROM users u
      JOIN roles r ON u.roleId = r.id
      WHERE u.email = ? AND u.password = ?
      ''',
      [email, password],
    );

    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  // Récupérer tous les étudiants depuis la table students
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT s.id, s.firstName, s.lastName, s.email, s.massar, g.name as groupName, g.filiere
      FROM students s
      LEFT JOIN groups g ON s.groupId = g.id
    ''');
  }

  // Ajouter un étudiant et créer automatiquement le compte académique
  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;

    // 1Insérer dans students
    final id = await db.insert('students', student);

    // 2 Créer le compte académique
    final firstName = student['firstName'] ?? '';
    final lastName = student['lastName'] ?? '';
    final massar = student['massar'] ?? '';

    final email = '${firstName.toLowerCase()}${lastName.toLowerCase()}@ump.com';

    // Vérifier si le compte existe déjà
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existing.isEmpty) {
      await db.insert('users', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': massar,
        'roleId': 1, // Étudiant
      });
    }

    return id;
  }

  // Mettre à jour un étudiant
  Future<int> updateStudent(int id, Map<String, dynamic> student) async {
    final db = await database;
    return await db.update(
      'students',
      student,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Supprimer un étudiant
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // pour voir l'absence de l'etudiant
  Future<List<Absence>> getAbsencesByStudent(int studentId) async {
  final db = await database;

  final result = await db.rawQuery('''
    SELECT 
      absences.id,
      modules.name AS moduleName,
      sessions.date,
      absences.status
    FROM absences
    INNER JOIN sessions ON absences.sessionId = sessions.id
    INNER JOIN modules ON sessions.moduleId = modules.id
    WHERE absences.studentId = ?
    ORDER BY sessions.date DESC
  ''', [studentId]);

  return result.map((row) {
    return Absence(
      id: row['id'] as int,
      moduleName: row['moduleName'] as String,
      date: row['date'] as String,
      status: row['status'] as String,
    );
  }).toList();
}

Future<void> markStudentPresent(int studentId, int sessionId) async {
  final db = await database;

  await db.insert(
    'absences',
    {
      'studentId': studentId,
      'sessionId': sessionId,
      'status': 'present',
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}




}

