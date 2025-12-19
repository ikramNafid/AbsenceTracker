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
      version: 4,
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

    // Table filieres
    await db.execute('''
      CREATE TABLE filieres(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Table groups
    await db.execute('''
      CREATE TABLE groups(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  idFiliere INTEGER,
  profId INTEGER,           
  FOREIGN KEY(idFiliere) REFERENCES filieres(id),
  FOREIGN KEY(profId) REFERENCES users(id)
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

    // Insérer filières par défaut
    await db.insert(
        'filieres', {'nom': 'IA', 'description': 'Intelligence Artificielle'});
    await db.insert(
        'filieres', {'nom': 'GINF', 'description': 'Génie Informatique'});
    await db.insert('filieres', {
      'nom': 'IRSI',
      'description': 'Informatique Réseaux et Systèmes d’Information'
    });
    await db.insert('filieres', {
      'nom': 'ROC',
      'description': 'Réseaux, Organisation et Communication'
    });

    // Insérer rôles par défaut
    await db.insert('roles', {'name': 'Etudiant'});
    await db.insert('roles', {'name': 'Professeur'});
    await db.insert('roles', {'name': 'Coordinateur'});
    await db.insert('roles', {'name': 'Admin'});

    // Insérer utilisateurs par défaut
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS filieres');
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

  // ================== Méthodes Filières ==================
  Future<List<Map<String, dynamic>>> getFilieres() async {
    final db = await database;
    return await db.query('filieres');
  }

  Future<int> insertFiliere(Map<String, dynamic> filiere) async {
    final db = await database;
    return await db.insert('filieres', filiere);
  }

  Future<int> deleteFiliere(int id) async {
    final db = await database;
    return await db.delete('filieres', where: 'id = ?', whereArgs: [id]);
  }

  // ================== Méthodes Groupes ==================
  Future<List<Map<String, dynamic>>> getGroups() async {
    final db = await database;
    return await db.query('groups');
  }

  Future<int> insertGroup(Map<String, dynamic> group) async {
    final db = await database;
    return await db.insert('groups', group);
  }

  Future<int> updateGroup(int id, Map<String, dynamic> group) async {
    final db = await database;
    return await db.update('groups', group, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGroup(int id) async {
    final db = await database;
    return await db.delete('groups', where: 'id = ?', whereArgs: [id]);
  }

  // ================== Login ==================
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT u.id, u.firstName, u.lastName, u.email, u.roleId, r.name as roleName
      FROM users u
      JOIN roles r ON u.roleId = r.id
      WHERE u.email = ? AND u.password = ?
    ''', [email, password]);

    if (res.isNotEmpty) return res.first;
    return null;
  }

  // ================== Étudiants ==================
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT s.id, s.firstName, s.lastName, s.email, s.massar, g.name as groupName, f.nom as filiere
      FROM students s
      LEFT JOIN groups g ON s.groupId = g.id
      LEFT JOIN filieres f ON f.id = g.idFiliere
    ''');
  }

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    final id = await db.insert('students', student);

    final firstName = student['firstName'] ?? '';
    final lastName = student['lastName'] ?? '';
    final massar = student['massar'] ?? '';
    final email = '${firstName.toLowerCase()}${lastName.toLowerCase()}@ump.com';

    final existing =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isEmpty) {
      await db.insert('users', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': massar,
        'roleId': 1,
      });
    }

    return id;
  }

  Future<int> updateStudent(int id, Map<String, dynamic> student) async {
    final db = await database;
    return await db
        .update('students', student, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // ================== Professeurs ==================
  Future<List<Map<String, dynamic>>> getProfesseurs() async {
    final db = await database;
    return await db.query('users', where: 'roleId = ?', whereArgs: [2]);
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ================== Coordinateurs ==================
  Future<List<Map<String, dynamic>>> getCoordinateurs() async {
    final db = await database;
    return await db.query('users', where: 'roleId = ?', whereArgs: [3]);
  }

  Future<int> insertCoordinateur(Map<String, dynamic> coord) async {
    final db = await database;
    return await db.insert('users', coord);
  }

  Future<int> updateCoordinateur(int id, Map<String, dynamic> coord) async {
    final db = await database;
    return await db.update('users', coord, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCoordinateur(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
  // ================== Absences ==================

// Récupérer les étudiants par groupe
  Future<List<Map<String, dynamic>>> getStudentsByGroup(int groupId) async {
    final db = await database;
    return await db.query(
      'students',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
  }

// Ajouter une absence
  Future<int> insertAbsence(Map<String, dynamic> absence) async {
    final db = await database;
    return await db.insert('absences', absence);
  }

// Récupérer les absences d'une session
  Future<List<Map<String, dynamic>>> getAbsencesBySession(int sessionId) async {
    final db = await database;
    return await db.query(
      'absences',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> assignProfToGroup(int groupId, int profId) async {
    final db = await database;
    return await db.update(
      'groups',
      {'profId': profId},
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }
}
