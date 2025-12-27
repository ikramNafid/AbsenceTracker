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

    // 🔹 Supprimer l’ancienne DB pour repartir à zéro (seulement en développement)
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 8, // ✅ OBLIGATOIRE
      onCreate: _createDB,
      // onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ======= CREATION DES TABLES =======
    await db.execute('''
      CREATE TABLE roles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE filieres(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        idFiliere INTEGER,
        FOREIGN KEY(idFiliere) REFERENCES filieres(id)
      )
    ''');

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

    await db.execute('''
      CREATE TABLE modules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        semester TEXT
      )
    ''');
    await db.execute('''
  CREATE TABLE module_groups(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    moduleId INTEGER NOT NULL,
    groupId INTEGER NOT NULL,
    FOREIGN KEY(moduleId) REFERENCES modules(id),
    FOREIGN KEY(groupId) REFERENCES groups(id)
  )
''');

    // APRÈS tables groups + modules

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

    await db.execute('''
  CREATE TABLE IF NOT EXISTS filiere_coordinateur(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filiereId INTEGER NOT NULL,
    coordinateurId INTEGER NOT NULL,
    FOREIGN KEY(filiereId) REFERENCES filieres(id),
    FOREIGN KEY(coordinateurId) REFERENCES users(id) -- remplacer "coordinateurId" par "coordinateurId"
  )
''');

    // ====== INSÉRER LES DONNÉES PAR DÉFAUT SI VIDE ======
    final rolesCount = await db.query('roles');
    if (rolesCount.isEmpty) {
      await db.insert('roles', {'name': 'Etudiant'});
      await db.insert('roles', {'name': 'Professeur'});
      await db.insert('roles', {'name': 'Coordinateur'});
      await db.insert('roles', {'name': 'Admin'});
    }

    final filieresCount = await db.query('filieres');
    if (filieresCount.isEmpty) {
      await db.insert('filieres',
          {'nom': 'IA', 'description': 'Intelligence Artificielle'});
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
    }

    final usersCount = await db.query('users');
    if (usersCount.isEmpty) {
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
  }

  // ======== GESTION MISE À JOUR DB ========

  // ==================  ==================
// 🔹 Récupérer la filière assignée à un coordinateur
  Future<Map<String, dynamic>?> getFiliereByCoordinateur(
      int coordinateurId) async {
    final db = await database;
    final res = await db.rawQuery('''
    SELECT f.id, f.nom, f.description
    FROM filiere_coordinateur fc
    JOIN filieres f ON fc.filiereId = f.id
    WHERE fc.coordinateurId = ?
  ''', [coordinateurId]);

    if (res.isNotEmpty) return res.first;
    return null;
  }

// 🔹 Récupérer les étudiants d'une filière
  Future<List<Map<String, dynamic>>> getStudentsByFiliere(int filiereId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT s.*
    FROM students s
    JOIN groups g ON s.groupId = g.id
    WHERE g.idFiliere = ?
  ''', [filiereId]);
  }

// 🔹 Récupérer les professeurs d'une filière
  Future<List<Map<String, dynamic>>> getProfessorsByFiliere(
      int filiereId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT u.*
    FROM users u
    JOIN filiere_coordinateur fc ON u.id = fc.coordinateurId
    JOIN filieres f ON fc.filiereId = f.id
    WHERE f.id = ? AND u.roleId = 2
  ''', [filiereId]);
  }

  // 🔹 Récupérer les modules d'une filière spécifique
  Future<List<Map<String, dynamic>>> getModulesByFiliere(int filiereId) async {
    final db = await database;
    final res = await db.rawQuery('''
    SELECT DISTINCT m.id, m.name, m.semester
    FROM modules m
    JOIN module_groups mg ON m.id = mg.moduleId
    JOIN groups g ON mg.groupId = g.id
    WHERE g.idFiliere = ?
  ''', [filiereId]);
    return res;
  }

// 🔹 Récupérer les modules avec leurs groupes pour une filière spécifique
  Future<List<Map<String, dynamic>>> getModulesWithGroupsByFiliere(
      int filiereId) async {
    final db = await database;

    // 🔹 Récupérer TOUS les modules
    final modules = await db.query('modules');

    List<Map<String, dynamic>> result = [];

    for (var m in modules) {
      final groupsData = await db.rawQuery('''
      SELECT g.name
      FROM module_groups mg
      JOIN groups g ON mg.groupId = g.id
      WHERE mg.moduleId = ? AND g.idFiliere = ?
    ''', [m['id'], filiereId]);

      result.add({
        'id': m['id'],
        'moduleName': m['name'],
        'groups': groupsData.map((g) => g['name']).toList(),
      });
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getModulesGrouped() async {
    final db = await database;

    final data = await db.rawQuery('''
    SELECT 
      m.name AS moduleName,
      g.name AS groupName
    FROM module_groups mg
    JOIN modules m ON mg.moduleId = m.id
    JOIN groups g ON mg.groupId = g.id
    ORDER BY m.name, g.name
  ''');

    return data;
  }

  // 🔹 Récupérer les groupes d'une filière spécifique
  Future<List<Map<String, dynamic>>> getGroupsByFiliere(int filiereId) async {
    final db = await database;
    return await db.query(
      'groups',
      where: 'idFiliere = ?',
      whereArgs: [filiereId],
    );
  }

  // 🔹 Affecter un module à un groupe
  Future<void> assignModuleToGroups(int moduleId, List<int> groupIds) async {
    final db = await database;
    for (var groupId in groupIds) {
      final existing = await db.query(
        'module_groups',
        where: 'moduleId = ? AND groupId = ?',
        whereArgs: [moduleId, groupId],
      );
      if (existing.isEmpty) {
        await db.insert('module_groups', {
          'moduleId': moduleId,
          'groupId': groupId,
        });
      }
    }
  }

// 🔹 Récupérer tous les modules avec leurs groupes
  Future<List<Map<String, dynamic>>> getModulesWithGroups() async {
    final db = await database;

    final modules = await db.query('modules');
    List<Map<String, dynamic>> result = [];

    for (var m in modules) {
      final groupsData = await db.rawQuery('''
      SELECT g.name 
      FROM module_groups mg
      JOIN groups g ON mg.groupId = g.id
      WHERE mg.moduleId = ?
    ''', [m['id']]);

      result.add({
        'id': m['id'],
        'name': m['name'],
        'semester': m['semester'],
        'groups': groupsData.map((g) => g['name']).toList(),
      });
    }
    return result;
  }

// 🔹 Récupérer les groupes d’un module
  Future<List<Map<String, dynamic>>> getGroupsByModule(int moduleId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT g.id, g.name 
    FROM groups g
    JOIN module_groups mg ON g.id = mg.groupId
    WHERE mg.moduleId = ?
  ''', [moduleId]);
  }

// 🔹 Récupérer les modules d’un groupe
  Future<List<Map<String, dynamic>>> getModulesByGroupManyToMany(
      int groupId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT m.id, m.name 
    FROM modules m
    JOIN module_groups mg ON m.id = mg.moduleId
    WHERE mg.groupId = ?
  ''', [groupId]);
  }

// 🔹 Supprimer l’affectation module ↔ groupe
  Future<int> removeModuleFromGroup(int moduleId, int groupId) async {
    final db = await database;
    return await db.delete(
      'module_groups',
      where: 'moduleId = ? AND groupId = ?',
      whereArgs: [moduleId, groupId],
    );
  }

  Future<bool> distributeStudentsToFilieres() async {
    try {
      final db = await instance.database;

      final students = await db.query('students');
      final groups = await db.query('groups');

      for (var student in students) {
        // Choisir un groupe de façon cyclique selon l'id de l'étudiant
        final group = groups[(student['id'] as int) % groups.length];
        await db.update(
          'students',
          {'groupId': group['id']}, // <- mettre à jour groupId, pas filiereId
          where: 'id = ?',
          whereArgs: [student['id']],
        );
      }
      return true;
    } catch (e) {
      print("Erreur répartition étudiants: $e");
      return false;
    }
  }

  // ================== MÉTHODES MODULES ==================

  // 🔹 Récupérer tous les modules
  Future<List<Map<String, dynamic>>> getModules() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.id, m.name, m.semester, g.name as groupName
      FROM modules m
      LEFT JOIN groups g ON m.groupId = g.id
    ''');
  }

  // 🔹 Récupérer les modules par groupe
  Future<List<Map<String, dynamic>>> getModulesByGroup(int groupId) async {
    final db = await database;
    return await db.query(
      'modules',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
  }

  // 🔹 Ajouter un module
  Future<int> insertModule(Map<String, dynamic> module) async {
    try {
      final db = await database;
      return await db.insert('modules', module);
    } catch (e) {
      print("Erreur insertModule: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllModules() async {
    final db = await database;
    return await db.query(
      'modules',
      columns: ['id', 'name', 'semester'],
    );
  }

  // 🔹 Modifier un module
  Future<int> updateModule(int id, Map<String, dynamic> module) async {
    final db = await database;
    return await db.update(
      'modules',
      module,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔹 Supprimer un module
  Future<int> deleteModule(int id) async {
    final db = await database;
    return await db.delete(
      'modules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================== MÉTHODES FILIÈRES ==================
  Future<List<Map<String, dynamic>>> getFilieres() async {
    final db = await database;
    return await db.query('filieres');
  }

  Future<int> insertFiliere(Map<String, dynamic> filiere) async {
    final db = await database;
    return await db.insert('filieres', filiere);
  }

  Future<int> updateFiliere(int id, Map<String, dynamic> filiere) async {
    final db = await database;
    return await db
        .update('filieres', filiere, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFiliere(int id) async {
    final db = await database;
    return await db.delete('filieres', where: 'id = ?', whereArgs: [id]);
  }

  // ================== MÉTHODES GROUPES ==================
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

  // ================== MÉTHODES ÉTUDIANTS ==================
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

  // ================== MÉTHODES PROFESSEURS ==================
  Future<List<Map<String, dynamic>>> getProfesseurs() async {
    final db = await database;
    return await db.query('users', where: 'roleId = ?', whereArgs: [2]);
  }

  // ================== MÉTHODES COORDINATEURS ==================
  Future<List<Map<String, dynamic>>> getCoordinateurs() async {
    final db = await database;
    return await db.query('users', where: 'roleId = ?', whereArgs: [3]);
  }

  Future<int> assignFiliereToCoordinateur(
      int filiereId, int coordinateurId) async {
    final db = await database;
    final existing = await db.query(
      'filiere_coordinateur',
      where: 'filiereId = ? AND coordinateurId = ?',
      whereArgs: [filiereId, coordinateurId],
    );
    if (existing.isNotEmpty) return 0;
    return await db.insert('filiere_coordinateur', {
      'filiereId': filiereId,
      'coordinateurId': coordinateurId,
    });
  }

  Future<List<Map<String, dynamic>>> getFiliereCoordinateurs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT fc.id, f.nom as filiere, u.firstName || ' ' || u.lastName as coordinateur
      FROM filiere_coordinateur fc
      JOIN filieres f ON fc.filiereId = f.id
      JOIN users u ON fc.coordinateurId = u.id
    ''');
  }
  // ================== DASHBOARD COUNTS ==================

  Future<int> getStudentsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM students');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getProfessorsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE roleId = ?',
      [2],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ================== MÉTHODES UTILISATEURS ==================
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

  // ================== LOGIN ==================
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

  // 🔹 Mettre à jour le groupe d’un étudiant
  Future<int> assignStudentToGroup(int studentId, int groupId) async {
    final db = await database;
    return await db.update(
      'students',
      {'groupId': groupId},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }
}
