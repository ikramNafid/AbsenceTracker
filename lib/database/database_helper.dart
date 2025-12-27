import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:absence_tracker/models/absence_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('absence_tracker.db');
    return _database!;
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    // Assurez-vous que le nom de la table est bien 'users'
    return await db.insert('users', row);
  }

  // ================= UPDATE =================
  Future<int> updateUser(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'users',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= DELETE =================
  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= GETTERS =================
  Future<List<Map<String, dynamic>>> getCoordinateurs() async {
    final db = await instance.database;
    // Supposons que roleId 3 est pour les coordinateurs
    return await db.query('users', where: 'roleId = ?', whereArgs: [3]);
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE roles (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)''');
    await db.execute(
        '''CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT, lastName TEXT, email TEXT UNIQUE, password TEXT, roleId INTEGER, FOREIGN KEY (roleId) REFERENCES roles (id))''');
    await db.execute(
        '''CREATE TABLE groups (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, filiere TEXT, coordinateurId INTEGER, FOREIGN KEY (coordinateurId) REFERENCES users (id))''');
    await db.execute(
        '''CREATE TABLE modules (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, filiere TEXT NOT NULL)''');
    await db.execute(
        '''CREATE TABLE students (id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT, lastName TEXT, email TEXT UNIQUE, massar TEXT, groupId INTEGER, FOREIGN KEY(groupId) REFERENCES groups (id))''');
    await db.execute(
        '''CREATE TABLE module_groups(id INTEGER PRIMARY KEY AUTOINCREMENT, moduleId INTEGER NOT NULL, groupId INTEGER NOT NULL, FOREIGN KEY(moduleId) REFERENCES modules(id), FOREIGN KEY(groupId) REFERENCES groups(id))''');
    await db.execute(
        '''CREATE TABLE sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, moduleId INTEGER, groupId INTEGER, moduleName TEXT, groupName TEXT, date TEXT, time TEXT, type TEXT, FOREIGN KEY (moduleId) REFERENCES modules (id), FOREIGN KEY (groupId) REFERENCES groups (id))''');
    await db.execute(
        '''CREATE TABLE absences (id INTEGER PRIMARY KEY AUTOINCREMENT, sessionId INTEGER, studentId INTEGER, status TEXT, note TEXT, UNIQUE(sessionId, studentId), FOREIGN KEY (sessionId) REFERENCES sessions (id), FOREIGN KEY (studentId) REFERENCES students (id))''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    await db.insert('roles', {'name': 'Etudiant'});
    await db.insert('roles', {'name': 'Professeur'});
    await db.insert('roles', {'name': 'Coordinateur'});
    await db.insert('roles', {'name': 'Admin'});

    await db.insert('users', {
      'firstName': 'Ikram',
      'lastName': 'Nafid',
      'email': 'ikram@ump.com',
      'password': '2003',
      'roleId': 1
    });
    await db.insert('users', {
      'firstName': 'Mohammed',
      'lastName': 'Boudchiche',
      'email': 'mohammed@ump.com',
      'password': '1234',
      'roleId': 2
    });
    await db.insert('users', {
      'firstName': 'Admin',
      'lastName': 'Admin',
      'email': 'admin@ump.com',
      'password': 'admin',
      'roleId': 4
    });

    await db.insert(
        'groups', {'id': 1, 'name': 'GI2', 'filiere': 'Génie Informatique'});
    await db.insert('sessions', {
      'moduleId': 101,
      'groupId': 1,
      'moduleName': 'Machine Learning',
      'groupName': 'GI2',
      'date': DateTime.now().toString().split(' ')[0],
      'time': '08:30',
      'type': 'Cours'
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS absences');
    await db.execute('DROP TABLE IF EXISTS sessions');
    await db.execute('DROP TABLE IF EXISTS module_groups');
    await db.execute('DROP TABLE IF EXISTS students');
    await db.execute('DROP TABLE IF EXISTS modules');
    await db.execute('DROP TABLE IF EXISTS groups');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS roles');
    await _createDB(db, newVersion);
  }

  // AUTH
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final res = await db.rawQuery(
        'SELECT u.id, u.firstName, u.lastName, u.email, u.roleId, r.name as roleName FROM users u JOIN roles r ON u.roleId = r.id WHERE u.email = ? AND u.password = ?',
        [email, password]);
    return res.isNotEmpty ? res.first : null;
  }

  // PROFESSEUR
  Future<List<Map<String, dynamic>>> getSessionsToday() async {
    final db = await database;
    final String today = DateTime.now().toString().split(' ')[0];
    return await db.query('sessions',
        where: 'date = ?', whereArgs: [today], orderBy: 'time ASC');
  }

  Future<List<Map<String, dynamic>>> getStudentsByGroup(int groupId) async {
    final db = await database;
    return await db.query('students',
        where: 'groupId = ?', whereArgs: [groupId], orderBy: 'lastName ASC');
  }

  // Récupérer les groupes filtrés par filière

// Récupérer les étudiants appartenant à une filière (via leur groupe)
  Future<List<Map<String, dynamic>>> getStudentsByFiliere(int filiereId) async {
    final db = await instance.database;
    // Note: Cette requête suppose que vous voulez voir les étudiants
    // dont le groupId actuel correspond à un groupe de cette filière.
    return await db.rawQuery('''
    SELECT students.* FROM students 
    JOIN groups ON students.groupId = groups.id 
    WHERE groups.filiere = (SELECT filiere FROM groups WHERE id = ?)
  ''', [filiereId]);
  }

  // ÉTUDIANTS
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.rawQuery(
        '''SELECT s.id, s.firstName, s.lastName, s.email, s.massar, s.groupId, g.name as groupName FROM students s LEFT JOIN groups g ON s.groupId = g.id''');
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
    final existing =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
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
    return await db
        .update('students', student, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }
// Dans le fichier database/database_helper.dart

  Future<int> updateStudentPassword(int studentId, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'students', // Assurez-vous que le nom de votre table est bien 'students'
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  Future<void> assignFiliereToCoordinateur(
      int filiereId, int coordinateurId) async {
    final db = await database;
    await db.update('groups', {'coordinateurId': coordinateurId},
        where: 'id = ?', whereArgs: [filiereId]);
  }

  Future<List<Map<String, dynamic>>> getFiliereCoordinateurs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.firstName || ' ' || u.lastName AS coordinateur, g.filiere AS filiere
      FROM groups g
      INNER JOIN users u ON g.coordinateurId = u.id
      WHERE u.roleId = 3
    ''');
  }

  // --- VERSION CORRIGÉE DE GETFILIERES ---
  Future<List<Map<String, dynamic>>> getFilieres() async {
    final db = await database;
    return await db.rawQuery(
        'SELECT DISTINCT id, filiere as nom, name as description FROM groups');
  }

  Future<int> insertFiliere(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
        'groups', {'name': data['description'] ?? '', 'filiere': data['nom']});
  }

  Future<int> updateFiliere(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
        'groups', {'name': data['description'], 'filiere': data['nom']},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFiliere(int id) async {
    final db = await database;
    return await db.delete('groups', where: 'id = ?', whereArgs: [id]);
  }

  // Récupérer tous les groupes
  Future<List<Map<String, dynamic>>> getGroups() async {
    final db = await database;
    return await db.query('groups');
  }

// Insérer un groupe
  Future<int> insertGroup(Map<String, dynamic> data) async {
    final db = await database;
    // On récupère le nom de la filière car votre table utilise 'filiere' (TEXT)
    // Note: Dans votre UI, vous envoyez 'idFiliere', nous allons donc ajuster cela
    return await db.insert('groups', {
      'name': data['name'],
      'filiere': data['filiereNom'], // On stocke le nom directement
    });
  }

// Mettre à jour un groupe
  Future<int> updateGroup(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'groups',
      {
        'name': data['name'],
        'filiere': data['filiereNom'],
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Supprimer un groupe
  Future<int> deleteGroup(int id) async {
    final db = await database;
    return await db.delete('groups', where: 'id = ?', whereArgs: [id]);
  }

  // Récupérer les groupes associés à une filière spécifique
  Future<List<Map<String, dynamic>>> getGroupsByFiliere(int filiereId) async {
    final db = await database;

    // 1. On récupère d'abord le nom de la filière correspondant à l'ID
    final filiereRes = await db.query('groups',
        columns: ['filiere'], where: 'id = ?', whereArgs: [filiereId]);

    if (filiereRes.isEmpty) return [];

    String filiereNom = filiereRes.first['filiere'] as String;

    // 2. On retourne tous les groupes qui ont ce nom de filière
    return await db.query(
      'groups',
      where: 'filiere = ?',
      whereArgs: [filiereNom],
    );
  }
  // Dans lib/database/database_helper.dart

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await instance.database;

    // On cherche l'utilisateur dans la table 'users'
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1, // On ne veut qu'un seul résultat
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    // Si rien n'est trouvé dans 'users', on peut chercher dans 'students'
    // si vous avez séparé les tables, sinon ignorez cette partie :
    final List<Map<String, dynamic>> studentResult = await db.query(
      'students',
      where:
          'email = ? AND massar = ?', // Pour les étudiants, le mot de passe est souvent le code Massar
      whereArgs: [email, password],
      limit: 1,
    );

    if (studentResult.isNotEmpty) {
      // On ajoute manuellement le roleId 1 pour identifier l'étudiant
      Map<String, dynamic> student = Map.of(studentResult.first);
      student['roleId'] = 1;
      return student;
    }

    return null; // Identifiants incorrects
  }

  // Récupérer uniquement les professeurs (roleId = 2)
  Future<List<Map<String, dynamic>>> getProfesseurs() async {
    final db = await instance.database;

    // On filtre par roleId = 2 (le rôle attribué aux profs dans vos formulaires)
    return await db.query(
      'users',
      where: 'roleId = ?',
      whereArgs: [2],
      orderBy: 'lastName ASC', // Optionnel : trier par nom
    );
  }

  Future<Map<String, dynamic>?> getFiliereByCoordinateur(
      int coordinateurId) async {
    final db = await instance.database;

    // On cherche la filière où le coordinateurId correspond
    final result = await db.query(
      'filieres',
      where: 'coordinateurId = ?',
      whereArgs: [coordinateurId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getProfessorsByFiliere(
      int filiereId) async {
    final db = await instance.database;

    // On récupère les utilisateurs qui sont des profs (roleId=2)
    // ET qui appartiennent à la filiere du coordinateur
    return await db.query(
      'users',
      where: 'roleId = ? AND filiereId = ?',
      whereArgs: [2, filiereId],
      orderBy: 'lastName ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getModulesWithGroupsByFiliere(
      int filiereId) async {
    final db = await instance.database;

    // Cette requête récupère les modules et fait une jointure avec les groupes
    // On suppose que la table 'modules' a une colonne 'filiereId'
    // et qu'il existe une table de liaison ou une colonne 'groupId'
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      m.id AS moduleId, 
      m.nom AS moduleNom, 
      g.id AS groupId, 
      g.nom AS groupeNom
    FROM modules m
    LEFT JOIN groupes g ON m.filiereId = g.filiereId
    WHERE m.filiereId = ?
  ''', [filiereId]);

    return result;
  }

  Future<void> assignModuleToGroups(int moduleId, List<int> groupIds) async {
    final db = await instance.database;

    // Utilisation d'une transaction pour s'assurer que tout est bien enregistré
    await db.transaction((txn) async {
      // 1. Supprimer les anciennes affectations pour ce module
      await txn.delete(
        'module_groupes',
        where: 'moduleId = ?',
        whereArgs: [moduleId],
      );

      // 2. Insérer les nouvelles affectations
      for (int groupId in groupIds) {
        await txn.insert('module_groupes', {
          'moduleId': moduleId,
          'groupId': groupId,
        });
      }
    });
  } // Assigner un étudiant à un groupe

  Future<int> assignStudentToGroup(int studentId, int groupId) async {
    final db = await instance.database;

    // On met à jour la table 'students' (ou 'users' selon votre structure)
    return await db.update(
      'students', // Remplacez par 'users' si vos étudiants sont dedans
      {'groupId': groupId},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  // Récupérer les modules avec les informations de leur filière
  Future<List<Map<String, dynamic>>> getModulesGrouped() async {
    final db = await instance.database;

    // On effectue une jointure (JOIN) pour avoir le nom de la filière avec le module
    return await db.rawQuery('''
    SELECT 
      modules.id, 
      modules.nom AS moduleNom, 
      filieres.nom AS filiereNom,
      modules.filiereId
    FROM modules
    INNER JOIN filieres ON modules.filiereId = filieres.id
    ORDER BY filieres.nom, modules.nom
  ''');
  }

  // Récupérer la liste de tous les modules
  Future<List<Map<String, dynamic>>> getAllModules() async {
    final db = await instance.database;

    // On récupère tout, trié par nom pour un affichage plus propre
    return await db.query('modules', orderBy: 'nom ASC');
  }

  // Supprimer un module par son ID
  Future<int> deleteModule(int id) async {
    final db = await instance.database;

    // On retourne le nombre de lignes supprimées (généralement 1)
    return await db.delete('modules', where: 'id = ?', whereArgs: [id]);
  }

  // Insérer un nouveau module
  Future<int> insertModule(Map<String, dynamic> row) async {
    final db = await instance.database;

    // 'row' doit contenir une clé 'nom' et éventuellement 'filiereId'
    return await db.insert('modules', row);
  }

  // Récupérer la liste des absences pour une session spécifique
  Future<List<Map<String, dynamic>>> getAbsencesBySession(int sessionId) async {
    final db = await instance.database;

    // On joint la table 'absences' avec 'students' pour avoir les détails de l'élève
    return await db.rawQuery('''
    SELECT 
      a.id AS absenceId,
      s.id AS studentId,
      s.firstName,
      s.lastName,
      a.status, -- 'Présent', 'Absent', ou 'Justifié'
      a.justification
    FROM absences a
    INNER JOIN students s ON a.studentId = s.id
    WHERE a.sessionId = ?
    ORDER BY s.lastName ASC
  ''', [sessionId]);
  }

  // Récupérer la liste des modules sans doublons
  Future<List<Map<String, dynamic>>> getDistinctModules() async {
    final db = await instance.database;

    // On utilise DISTINCT pour éviter d'avoir le même module plusieurs fois
    return await db
        .rawQuery('SELECT DISTINCT id, nom FROM modules ORDER BY nom ASC');
  }

  // Récupérer une session spécifique par son ID avec les noms du module et du groupe
  Future<Map<String, dynamic>?> getSessionById(int sessionId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      s.*, 
      m.nom AS moduleNom, 
      g.nom AS groupeNom
    FROM sessions s
    JOIN modules m ON s.moduleId = m.id
    JOIN groupes g ON s.groupId = g.id
    WHERE s.id = ?
  ''', [sessionId]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Enregistrer ou mettre à jour une absence
  Future<int> insertAbsence(Map<String, dynamic> row) async {
    final db = await instance.database;

    // 'row' doit contenir : studentId, sessionId, status (Présent/Absent), date, etc.
    return await db.insert(
      'absences',
      row,
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Évite les doublons pour une même session
    );
  }

  // Récupérer les sessions pour une date précise
  Future<List<Map<String, dynamic>>> getSessionsByDate(String date) async {
    final db = await instance.database;

    // On joint avec les modules et groupes pour avoir les noms lisibles
    return await db.rawQuery('''
    SELECT 
      s.*, 
      m.nom AS moduleNom, 
      g.nom AS groupeNom
    FROM sessions s
    JOIN modules m ON s.moduleId = m.id
    JOIN groupes g ON s.groupId = g.id
    WHERE s.date = ?
    ORDER BY s.heureDebut ASC
  ''', [date]);
  }

  // Récupérer les groupes qui étudient un module spécifique (par son nom)
  Future<List<Map<String, dynamic>>> getGroupsByModuleName(
      String moduleName) async {
    final db = await instance.database;

    // Cette requête suppose que les modules et les groupes sont liés par la filière
    // ou par une table de liaison 'module_groupes'
    return await db.rawQuery('''
    SELECT g.* FROM groupes g
    INNER JOIN modules m ON g.filiereId = m.filiereId
    WHERE m.nom = ?
  ''', [moduleName]);
  }

  // Mettre à jour le mot de passe d'un professeur (ou tout utilisateur par son ID)
  Future<int> updateProfessorPassword(int userId, String newPassword) async {
    final db = await instance.database;

    return await db.update(
      'users',
      {'password': newPassword}, // On met à jour la colonne password
      where: 'id = ?', // Pour l'utilisateur ayant cet ID
      whereArgs: [userId],
    );
  }

  // Récupérer la liste complète de toutes les absences avec détails
  Future<List<Map<String, dynamic>>> getAllAbsences() async {
    final db = await instance.database;

    // On récupère les infos de l'étudiant, du module et de la session pour chaque absence
    return await db.rawQuery('''
    SELECT 
      a.id AS absenceId,
      s.firstName,
      s.lastName,
      m.nom AS moduleNom,
      sess.date,
      a.status
    FROM absences a
    JOIN students s ON a.studentId = s.id
    JOIN sessions sess ON a.sessionId = sess.id
    JOIN modules m ON sess.moduleId = m.id
    ORDER BY sess.date DESC
  ''');
  }

  Future<Map<String, dynamic>?> getStudentProfile(int studentId) async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      s.firstName,
      s.lastName,
      s.email,
      s.massar,
      g.name AS groupName,
      g.filiere
    FROM students s
    LEFT JOIN groups g ON s.groupId = g.id
    WHERE s.id = ?
  ''', [studentId]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
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

  // Dans lib/database/database_helper.dart

  Future<List<Absence>> getAbsencesByStudent(int studentId) async {
    final db = await instance.database; // Ici 'database' est reconnu

    final result = await db.rawQuery('''
    SELECT 
      absences.id,
      absences.studentId,
      students.name AS studentName,
      students.groupName AS groupName,
      modules.name AS moduleName,
      sessions.date,
      absences.status
    FROM absences
    INNER JOIN students ON absences.studentId = students.id
    INNER JOIN sessions ON absences.sessionId = sessions.id
    INNER JOIN modules ON sessions.moduleId = modules.id
    WHERE absences.studentId = ?
    ORDER BY sessions.date DESC
  ''', [studentId]);

    return result.map((row) => Absence.fromMap(row)).toList();
  }
}
