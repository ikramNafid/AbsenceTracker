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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Table Groupes
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // 2. Table Professeurs
    await db.execute('''
      CREATE TABLE professors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role INTEGER
      )
    ''');

    // Insertion du prof par défaut
    await db.insert('professors', {
      'firstName': 'Mohammed',
      'lastName': 'Boudchiche',
      'email': 'mohammed.boudchiche@ump.com',
      'password': '1234',
      'role': 2
    });

    // 3. Table Modules (Optionnelle si vous utilisez moduleName dans sessions)
    await db.execute('''
      CREATE TABLE modules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        semester TEXT,
        groupId INTEGER,
        FOREIGN KEY(groupId) REFERENCES groups (id)
      )
    ''');

    // 4. Table Étudiants
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER,
        firstName TEXT,
        lastName TEXT,
        email TEXT UNIQUE,
        FOREIGN KEY (groupId) REFERENCES groups (id)
      )
    ''');

    // 5. Table Sessions (La plus importante pour votre affichage)
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moduleId INTEGER,
        groupId INTEGER,
        moduleName TEXT,
        groupName TEXT,
        date TEXT,
        time TEXT,
        type TEXT,
        FOREIGN KEY (moduleId) REFERENCES modules (id),
        FOREIGN KEY (groupId) REFERENCES groups (id)
      )
    ''');

    // 6. Table Absences
    await db.execute('''
      CREATE TABLE absences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        studentId INTEGER,
        status TEXT,
        note TEXT,
        UNIQUE(sessionId, studentId), 
        FOREIGN KEY (sessionId) REFERENCES sessions (id),
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    // Insertion des données de test (Machine Learning, C++, etc.)
    await insertRealTestData(db);
  }

  // ================== INSERTION DES DONNÉES DE TEST ==================
  Future<void> insertRealTestData(Database db) async {
    // 1. Création des Groupes
    int idGI2 = await db.insert('groups', {'name': 'GI2'});
    int idIA2 = await db.insert('groups', {'name': 'IA2'});
    int idCP1 = await db.insert('groups', {'name': 'CP1'});

    // 2. Création des Étudiants
    await db.insert('students', {
      'groupId': idGI2,
      'firstName': 'Karim',
      'lastName': 'Benani',
      'email': 'karim@ump.com'
    });
    await db.insert('students', {
      'groupId': idGI2,
      'firstName': 'Yassine',
      'lastName': 'Mansouri',
      'email': 'yassine@ump.com'
    });
    await db.insert('students', {
      'groupId': idIA2,
      'firstName': 'Sami',
      'lastName': 'Hassan',
      'email': 'sami@ump.com'
    });
    await db.insert('students', {
      'groupId': idCP1,
      'firstName': 'Laila',
      'lastName': 'Amrani',
      'email': 'laila@ump.com'
    });

    // 3. Création des Sessions (Aujourd'hui)
    String today = DateTime.now().toIso8601String().split('T')[0];

    await db.insert('sessions', {
      'moduleName': 'Machine Learning',
      'groupName': 'GI2',
      'groupId': idGI2,
      'date': today,
      'time': '08:30',
      'type': 'Cours'
    });

    await db.insert('sessions', {
      'moduleName': 'Machine Learning',
      'groupName': 'IA2',
      'groupId': idIA2,
      'date': today,
      'time': '10:30',
      'type': 'TP'
    });

    await db.insert('sessions', {
      'moduleName': 'C++',
      'groupName': 'CP1',
      'groupId': idCP1,
      'date': today,
      'time': '14:00',
      'type': 'Cours'
    });
  }

  // ================== MÉTHODES DE RÉCUPÉRATION ==================

  Future<List<Map<String, dynamic>>> getDistinctModules() async {
    final db = await instance.database;
    return await db.rawQuery(
        'SELECT DISTINCT moduleName as name FROM sessions WHERE moduleName IS NOT NULL');
  }

  Future<List<Map<String, dynamic>>> getGroupsByModuleName(
      String moduleName) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT DISTINCT groupId as id, groupName as name 
      FROM sessions 
      WHERE moduleName = ?
    ''', [moduleName]);
  }

  Future<List<Map<String, dynamic>>> getSessionsToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await getSessionsByDate(
        today); // Appel de la méthode que nous venons d'ajouter
  }

  Future<List<Map<String, dynamic>>> getStudentsByGroup(int groupId) async {
    final db = await database;
    return await db.query('students',
        where: 'groupId = ?', whereArgs: [groupId], orderBy: 'lastName');
  }

  Future<Map<String, dynamic>?> loginProfessor(
      String email, String password) async {
    final db = await instance.database;
    final res = await db.query('professors',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> insertAbsence(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('absences', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAbsencesBySession(int sessionId) async {
    final db = await database;
    return await db
        .query('absences', where: 'sessionId = ?', whereArgs: [sessionId]);
  }

  Future<Map<String, dynamic>> getSessionById(int id) async {
    final db = await instance.database;
    final res = await db.query('sessions', where: 'id = ?', whereArgs: [id]);
    return res.first;
  }

  // Cette méthode permet de récupérer les séances pour une date précise
  Future<List<Map<String, dynamic>>> getSessionsByDate(String date) async {
    final db = await instance.database;
    return await db.query('sessions', where: 'date = ?', whereArgs: [date]);
  }
  // ================== MÉTHODES COMPLÉMENTAIRES ==================

  // Nécessaire pour la page Statistiques
  Future<List<Map<String, dynamic>>> getAllAbsences() async {
    final db = await instance.database;
    return await db.query('absences');
  }

  // Nécessaire pour la page Profil (Changement de mot de passe)
  Future<int> updateProfessorPassword(int id, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'professors',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
