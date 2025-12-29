import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "../models/absence_model.dart";

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

    // Ne jamais supprimer la DB en production
    // 🔹 Décommenter uniquement si tu veux réinitialiser la DB volontairement
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 13,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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
  CREATE TABLE module_professeur (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    moduleId INTEGER NOT NULL,
    professeurId INTEGER NOT NULL,
    FOREIGN KEY(moduleId) REFERENCES modules(id),
    FOREIGN KEY(professeurId) REFERENCES users(id)
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS profseance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        professeurId INTEGER NOT NULL,
        sessionId INTEGER NOT NULL,
        FOREIGN KEY(professeurId) REFERENCES users(id),
        FOREIGN KEY(sessionId) REFERENCES sessions(id)
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
      await db.insert('filieres', {
        'nom': 'IA',
        'description': 'Intelligence Artificielle',
      });
      await db.insert('filieres', {
        'nom': 'GINF',
        'description': 'Génie Informatique',
      });
      await db.insert('filieres', {
        'nom': 'IRSI',
        'description': 'Informatique Réseaux et Systèmes d’Information',
      });
      await db.insert('filieres', {
        'nom': 'ROC',
        'description': 'Robotique,objets connectés',
      });
    }

    final usersCount = await db.query('users');
    if (usersCount.isEmpty) {
      // await db.insert('users', {
      //   'firstName': 'Ikram',
      //   'lastName': 'Nafid',
      //   'email': 'ikram@ump.com',
      //   'password': '2003',
      //   'roleId': 1,
      // });

      // await db.insert('users', {
      //   'firstName': 'Mohammed',
      //   'lastName': 'Boudchiche',
      //   'email': 'mohammed@ump.com',
      //   'password': '1234',
      //   'roleId': 2,
      // });

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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 13) {
      await db.execute('''
      CREATE TABLE module_professeur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moduleId INTEGER NOT NULL,
        professeurId INTEGER NOT NULL,
        FOREIGN KEY(moduleId) REFERENCES modules(id),
        FOREIGN KEY(professeurId) REFERENCES users(id)
      );
    ''');
    }
  }
  // ================== AFFECTATION MODULE → PROF ==================

  // ================== PROFESSEURS AVEC MODULES ==================

  // ================== AFFECTATION MODULE → PROF ==================

  // Future<void> affecterModuleAProf(int moduleId, int profId) async {
  //   final db = await database;

  //   final existing = await db.query(
  //     'module_professeur',
  //     where: 'moduleId = ? AND professeurId = ?',
  //     whereArgs: [moduleId, profId],
  //   );

  //   if (existing.isEmpty) {
  //     await db.insert('module_professeur', {
  //       'moduleId': moduleId,
  //       'professeurId': profId,
  //     });
  //   }
  // }

  // ================== PROFESSEURS AVEC MODULES ==================

  Future<List<Map<String, dynamic>>> getProfesseursWithModules() async {
    final db = await database;

    final data = await db.rawQuery('''
    SELECT 
      u.id AS profId,
      u.firstName || ' ' || u.lastName AS professeur,
      m.id AS moduleId,
      m.name AS module,
      g.name AS groupe
    FROM module_professeur mp
    JOIN users u ON mp.professeurId = u.id
    JOIN modules m ON mp.moduleId = m.id
    LEFT JOIN module_groups mg ON m.id = mg.moduleId
    LEFT JOIN groups g ON mg.groupId = g.id
    WHERE u.roleId = 2
    ORDER BY professeur, module
  ''');

    return data;
  }
  // DatabaseHelper.dart

  Future<void> affecterModuleAProf(int moduleId, int profId) async {
    final db = await database;

    // Vérifier si l'affectation existe déjà
    final existing = await db.query(
      'module_professeur',
      where: 'moduleId = ? AND professeurId = ?',
      whereArgs: [moduleId, profId],
    );

    if (existing.isEmpty) {
      await db.insert('module_professeur', {
        'moduleId': moduleId,
        'professeurId': profId,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getModulesByProfesseur(int profId) async {
    final db = await database;
    final data = await db.rawQuery(
        ''' SELECT m.id, m.name, m.semester FROM module_professeur mp 
        JOIN modules m ON mp.moduleId = m.id WHERE mp.professeurId = ? ''',
        [profId]);
    return data;
  }

  // ======== GESTION MISE À JOUR DB ========
  Future<List<Map<String, dynamic>>> getStudentsByGroup(int groupId) async {
    final db = await database;
    return await db
        .query('students', where: 'groupId = ?', whereArgs: [groupId]);
  }

  Future<List<Map<String, dynamic>>> getAbsencesBySession(int sessionId) async {
    final db = await database;
    return await db.query(
      'absences',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<Map<String, dynamic>>> getDistinctModules() async {
    final db = await instance.database;
    return await db.rawQuery(
      'SELECT DISTINCT moduleName as name FROM sessions WHERE moduleName IS NOT NULL',
    );
  }

  Future<int> insertAbsence(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'absences',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getSessionById(int id) async {
    final db = await instance.database;
    final res = await db.query('sessions', where: 'id = ?', whereArgs: [id]);
    return res.first;
  }

  Future<List<Map<String, dynamic>>> getSessionsByDate(String date) async {
    final db = await instance.database;
    return await db.query('sessions', where: 'date = ?', whereArgs: [date]);
  }

  Future<List<Map<String, dynamic>>> getSessionsToday() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // 🔹 LEFT JOIN pour éviter les plantages si module_groups ou groups est vide
    final result = await db.rawQuery('''
    SELECT 
      s.id,
      s.time,
      s.date,
      m.name AS moduleName,
      g.name AS groupName
    FROM sessions s
    LEFT JOIN modules m ON s.moduleId = m.id
    LEFT JOIN module_groups mg ON m.id = mg.moduleId
    LEFT JOIN groups g ON mg.groupId = g.id
    WHERE s.date = ?
      AND m.name IN ('Administration Système Linux', 'Système d\'Exploitation')
    ORDER BY s.time
  ''', [today]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getGroupsByModuleName(
    String moduleName,
  ) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT DISTINCT groupId as id, groupName as name 
      FROM sessions 
      WHERE moduleName = ?
    ''',
      [moduleName],
    );
  }
  // ==================  ==================

  // 🔹 Récupérer la filière assignée à un coordinateur
  Future<Map<String, dynamic>?> getFiliereByCoordinateur(
    int coordinateurId,
  ) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
    SELECT f.id, f.nom, f.description
    FROM filiere_coordinateur fc
    JOIN filieres f ON fc.filiereId = f.id
    WHERE fc.coordinateurId = ?
  ''',
      [coordinateurId],
    );

    if (res.isNotEmpty) return res.first;
    return null;
  }

  // 🔹 Récupérer les étudiants d'une filière
  Future<List<Map<String, dynamic>>> getStudentsByFiliere(int filiereId) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT s.*
    FROM students s
    JOIN groups g ON s.groupId = g.id
    WHERE g.idFiliere = ?
  ''',
      [filiereId],
    );
  }

  // 🔹 Récupérer les professeurs d'une filière
  Future<List<Map<String, dynamic>>> getProfessorsByFiliere(
    int filiereId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT u.*
    FROM users u
    JOIN filiere_coordinateur fc ON u.id = fc.coordinateurId
    JOIN filieres f ON fc.filiereId = f.id
    WHERE f.id = ? AND u.roleId = 2
  ''',
      [filiereId],
    );
  }

  // 🔹 Récupérer les modules d'une filière spécifique
  Future<List<Map<String, dynamic>>> getModulesByFiliere(int filiereId) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT DISTINCT m.id, m.name, m.semester
    FROM modules m
    JOIN module_groups mg ON m.id = mg.moduleId
    JOIN groups g ON mg.groupId = g.id
    WHERE g.idFiliere = ?
  ''',
      [filiereId],
    );
  }

  // 🔹 Récupérer les modules avec leurs groupes pour une filière spécifique
  Future<List<Map<String, dynamic>>> getModulesWithGroupsByFiliere(
    int filiereId,
  ) async {
    final db = await database;

    // 🔹 Récupérer TOUS les modules
    final modules = await db.query('modules');

    List<Map<String, dynamic>> result = [];

    for (var m in modules) {
      final groupsData = await db.rawQuery(
        '''
      SELECT g.name
      FROM module_groups mg
      JOIN groups g ON mg.groupId = g.id
      WHERE mg.moduleId = ? AND g.idFiliere = ?
    ''',
        [m['id'], filiereId],
      );

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
      final groupsData = await db.rawQuery(
        '''
      SELECT g.name 
      FROM module_groups mg
      JOIN groups g ON mg.groupId = g.id
      WHERE mg.moduleId = ?
    ''',
        [m['id']],
      );

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
    return await db.rawQuery(
      '''
    SELECT g.id, g.name 
    FROM groups g
    JOIN module_groups mg ON g.id = mg.groupId
    WHERE mg.moduleId = ?
  ''',
      [moduleId],
    );
  }

  // 🔹 Récupérer les modules d’un groupe
  Future<List<Map<String, dynamic>>> getModulesByGroupManyToMany(
    int groupId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT m.id, m.name 
    FROM modules m
    JOIN module_groups mg ON m.id = mg.moduleId
    WHERE mg.groupId = ?
  ''',
      [groupId],
    );
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
  Future<int> updateProfessorPassword(int id, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'professors',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllAbsences() async {
    final db = await instance.database;
    return await db.query('absences');
  }

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
    return await db.query('modules', columns: ['id', 'name', 'semester']);
  }

  // 🔹 Modifier un module
  Future<int> updateModule(int id, Map<String, dynamic> module) async {
    final db = await database;
    return await db.update('modules', module, where: 'id = ?', whereArgs: [id]);
  }

  // 🔹 Supprimer un module
  Future<int> deleteModule(int id) async {
    final db = await database;
    return await db.delete('modules', where: 'id = ?', whereArgs: [id]);
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
    return await db.update(
      'filieres',
      filiere,
      where: 'id = ?',
      whereArgs: [id],
    );
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

    // Créer l'email automatiquement
    final firstName = student['firstName'] ?? '';
    final lastName = student['lastName'] ?? '';
    final massar = student['massar'] ?? '';
    final email = '${firstName.toLowerCase()}${lastName.toLowerCase()}@ump.com';

    // Insérer dans students
    final id = await db.insert('students', {
      'firstName': firstName,
      'lastName': lastName,
      'massar': massar,
      'email': email,
      'groupId': student['groupId'],
    });

    // Créer automatiquement le compte utilisateur si pas déjà existant
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
        'roleId': 1, // rôle Etudiant
      });
    }

    return id;
  }

  Future<int> updateStudent(int id, Map<String, dynamic> student) async {
    final db = await database;
    return await db.update(
      'students',
      student,
      where: 'id = ?',
      whereArgs: [id],
    );
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
    int filiereId,
    int coordinateurId,
  ) async {
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
    final res = await db.rawQuery(
      '''
      SELECT u.id, u.firstName, u.lastName, u.email, u.roleId, r.name as roleName
      FROM users u
      JOIN roles r ON u.roleId = r.id
      WHERE u.email = ? AND u.password = ?
    ''',
      [email, password],
    );

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

  //========================================MARIAME======================
  Future<Map<String, dynamic>?> getStudentProfile(int id) async {
    final db = await database;
    // Utiliser la bonne table et la bonne colonne
    final result = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final student = result.first; // Récupérer le groupe
      final group = await db.query(
        'groups',
        where: 'id = ?',
        whereArgs: [student['groupId']],
      );
      student['groupName'] = group.isNotEmpty ? group.first['name'] : null;
      // Récupérer la filière via le groupe
      if (group.isNotEmpty && group.first['idFiliere'] != null) {
        final filiere = await db.query(
          'filieres',
          where: 'id = ?',
          whereArgs: [group.first['idFiliere']],
        );
        student['filiere'] =
            filiere.isNotEmpty ? filiere.first['nom'] : 'Non assignée';
      } else {
        student['filiere'] = 'Non assignée';
      }
      return student;
    } else {
      return null;
    }
  }

  Future<List<Absence>> getAbsencesByStudent(int studentId) async {
    final db = await database;
    final result = await db.rawQuery(
        ''' SELECT absences.id, modules.name AS moduleName, sessions.date, absences.status FROM absences
         INNER JOIN sessions ON absences.sessionId = sessions.id INNER JOIN modules
          ON sessions.moduleId = modules.id WHERE absences.studentId = ? ORDER BY sessions.date DESC ''',
        [studentId]);
    return result.map((row) {
      return Absence(
        id: row['id'] as int,
        moduleName: row['moduleName'] as String,
        date: row['date'] as String,
        status: row['status'] as String,
      );
    }).toList();
  }
  // ====================== MÉTHODES PROFSEANCE ======================

  // Assigner une séance à un professeur
  Future<void> assignSessionToProf(int profId, int sessionId) async {
    final db = await database;
    final existing = await db.query(
      'profseance',
      where: 'professeurId = ? AND sessionId = ?',
      whereArgs: [profId, sessionId],
    );
    if (existing.isEmpty) {
      await db.insert('profseance', {
        'professeurId': profId,
        'sessionId': sessionId,
      });
    }
  }

  // Récupérer les séances du jour pour un professeur
  Future<List<Map<String, dynamic>>> getTodaySessionsByProf(int profId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery('''
    SELECT s.id, s.time, s.date, s.type, m.name AS moduleName, g.name AS groupName, g.id AS groupId
    FROM sessions s
    JOIN module_groups mg ON mg.moduleId = s.moduleId
    JOIN groups g ON mg.groupId = g.id
    JOIN profseance p ON p.sessionId = s.id
    JOIN modules m ON s.moduleId = m.id
    WHERE p.professeurId = ? AND s.date = ?
  ''', [profId, today]);
    return result;
  }

  // DatabaseHelper.dart
  Future<void> insertDefaultSessions() async {
    final db = await database;

    // Vérifier si la table sessions est vide
    final sessionsCount = await db.query('sessions');
    if (sessionsCount.isNotEmpty) return; // déjà rempli

    // Récupérer les modules spécifiques
    final moduleAdmin = await db.query(
      'modules',
      where: 'name = ?',
      whereArgs: ['Administration Système Linux'],
    );
    final moduleSys = await db.query(
      'modules',
      where: 'name = ?',
      whereArgs: ['Système d\'Exploitation'],
    );

    if (moduleAdmin.isEmpty || moduleSys.isEmpty) {
      print('Modules par défaut non trouvés !');
      return;
    }

    final moduleAdminId = moduleAdmin.first['id'] as int;
    final moduleSysId = moduleSys.first['id'] as int;

    // Récupérer les groupes spécifiques
    final groupIRSI2 = await db.query(
      'groups',
      where: 'name = ?',
      whereArgs: ['IRSI2'],
    );
    final groupIRSI1A = await db.query(
      'groups',
      where: 'name = ?',
      whereArgs: ['IRSI1-A'],
    );

    if (groupIRSI2.isEmpty || groupIRSI1A.isEmpty) {
      print('Groupes par défaut non trouvés !');
      return;
    }

    final groupIRSI2Id = groupIRSI2.first['id'] as int;
    final groupIRSI1AId = groupIRSI1A.first['id'] as int;

    // Date d'aujourd'hui
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // 🔹 Insérer les deux séances
    await db.insert('sessions', {
      'moduleId': moduleAdminId,
      'date': today,
      'time': '08:30',
      'type': 'Cours',
    });

    await db.insert('sessions', {
      'moduleId': moduleSysId,
      'date': today,
      'time': '10:15',
      'type': 'Cours',
    });

    print('Séances par défaut insérées avec succès !');
  }

  Future<List<Map<String, dynamic>>> getDefaultTodaySessions(int profId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final result = await db.rawQuery('''
    SELECT s.id, s.date, s.time, s.type, m.name AS moduleName, g.name AS groupName, g.id AS groupId
    FROM profseance pf
    JOIN sessions s ON pf.sessionId = s.id
    JOIN modules m ON s.moduleId = m.id
    LEFT JOIN module_groups mg ON m.id = mg.moduleId
    LEFT JOIN groups g ON mg.groupId = g.id
    WHERE pf.professeurId = ? 
      AND s.date = ?
      AND m.name IN ('Administration Système Linux', 'Système d\'Exploitation')
    ORDER BY s.time
  ''', [profId, today]);

    return result;
  }
}
