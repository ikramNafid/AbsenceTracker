import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:absence_tracker/models/session_model.dart';

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
    // Insérer les groupes par défaut si ils n'existent pas
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM groups'),
    );

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
        name TEXT NOT NULL,
        group_name TEXT NOT NULL
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

    // Insertions par défaut
    await db.insert('roles', {'name': 'Etudiant'});
    await db.insert('roles', {'name': 'Professeur'});
    await db.insert('roles', {'name': 'Coordinateur'});
    await db.insert('roles', {'name': 'Admin'});

    await db.insert(
        'filieres', {'nom': 'IA', 'description': 'Intelligence Artificielle'});
    await db.insert(
        'filieres', {'nom': 'GINF', 'description': 'Génie Informatique'});
    await db.insert('filieres',
        {'nom': 'IRSI', 'description': 'Informatique Réseaux et Systèmes'});
    await db.insert('filieres', {
      'nom': 'ROC',
      'description': 'Réseaux, Organisation et Communication'
    });

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

    await db.insert(
        'groups', {'id': 1, 'name': 'GI2', 'idFiliere': 1, 'profId': 1});
    await db.insert(
        'groups', {'id': 2, 'name': 'IA2', 'idFiliere': 1, 'profId': 1});

    // Dans _createDB ou dans un initData après la création des tables
    await db.insert('modules', {
      'name': 'Développement Mobile',
      'semester': 'S1',
      'groupId': 1, // Associer à GI2
    });
    await db.insert('modules', {
      'name': 'C++',
      'semester': 'S2',
      'groupId': 2, // Associer à IA2
    });
    await db.insert('modules', {
      'name': 'Machine Learning',
      'semester': 'S2',
      'groupId': 1, // Associer à GI2
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
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

  // ================== Méthodes Sessions ==================
  Future<List<SessionModel>> getSessions() async {
    final db = await database;
    final result = await db.query('sessions', orderBy: 'id');
    return result.map((json) => SessionModel.fromMap(json)).toList();
  }

  Future<int> addSession(SessionModel session) async {
    final db = await database;
    return await db.insert('sessions', session.toMap());
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
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

  // ================== Filières ==================
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

  // ================== Groupes ==================
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

  // ================== Étudiants ==================
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query('students');
  }

  // Récupérer les étudiants d’un groupe spécifique
  Future<List<Map<String, dynamic>>> getStudentsByGroup(int groupId) async {
    final db = await database;
    return await db.query(
      'students',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
  }

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student);
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

  // ================== Absences ==================
  Future<List<Map<String, dynamic>>> getAbsencesBySession(int sessionId) async {
    final db = await database;
    return await db
        .query('absences', where: 'sessionId = ?', whereArgs: [sessionId]);
  }

  Future<int> insertAbsence(Map<String, dynamic> absence) async {
    final db = await database;
    return await db.insert('absences', absence);
  }

  //-----------------------
  // ================== Méthode pour récupérer les groupes avec module et étudiants ==================
  Future<List<Map<String, dynamic>>> getGroupsWithModuleAndStudents() async {
    final db = await database;

    final groups = await db.query('groups');

    List<Map<String, dynamic>> result = [];

    for (var group in groups) {
      // Récupérer le module du groupe (si existant)
      final moduleData = await db.query(
        'modules',
        where: 'groupId = ?',
        whereArgs: [group['id']],
      );
      String moduleName =
          moduleData.isNotEmpty && moduleData.first['name'] != null
              ? moduleData.first['name']!.toString()
              : '';

      // Récupérer les étudiants du groupe
      final studentsData = await db.query(
        'students',
        where: 'groupId = ?',
        whereArgs: [group['id']],
      );
      List<String> studentsNames = studentsData
          .map((s) => '${s['firstName']} ${s['lastName']}')
          .toList();

      result.add({
        'name': group['name'],
        'module': moduleName,
        'students': studentsNames,
      });
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getModulesWithGroupAndStudents() async {
    final db = await database;

    final modules = await db.query('modules');

    List<Map<String, dynamic>> result = [];

    for (var module in modules) {
      // Récupérer le groupe associé
      final groupData = await db.query(
        'groups',
        where: 'id = ?',
        whereArgs: [module['groupId']],
      );
      String groupName = groupData.isNotEmpty && groupData.first['name'] != null
          ? groupData.first['name']!.toString()
          : 'Aucun';

      // Récupérer les étudiants du groupe
      List<String> studentsNames = [];
      if (groupData.isNotEmpty) {
        final studentsData = await db.query(
          'students',
          where: 'groupId = ?',
          whereArgs: [groupData.first['id']],
        );
        studentsNames = studentsData
            .map((s) => '${s['firstName']} ${s['lastName']}')
            .toList();
      }

      result.add({
        'moduleName': module['name'],
        'semester': module['semester'],
        'groupName': groupName,
        'students': studentsNames,
      });
    }

    return result;
  }

  // Récupérer tous les modules avec leur groupe associé
  Future<List<Map<String, dynamic>>> getModules() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT m.id, m.name, m.semester, g.id as groupId, g.name as groupName
    FROM modules m
    LEFT JOIN groups g ON m.groupId = g.id
  ''');
  }

  // Récupérer tous les modules avec leur groupe
  Future<List<Map<String, dynamic>>> getModulesWithGroup() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT m.id, m.name, m.semester, g.name as groupName
    FROM modules m
    LEFT JOIN groups g ON m.groupId = g.id
    ORDER BY m.id
  ''');
  }

// Récupérer les groupes d’un module
  Future<List<Map<String, dynamic>>> getGroupsByModule(int moduleId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT g.id, g.name
    FROM groups g
    INNER JOIN modules m ON m.groupId = g.id
    WHERE m.id = ?
  ''', [moduleId]);
  }
}
