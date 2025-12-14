import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('absence_tracker.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groups(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        filiere TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER,
        massar TEXT,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        FOREIGN KEY(groupId) REFERENCES groups(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE modules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        semester TEXT,
        groupId INTEGER,
        FOREIGN KEY(groupId) REFERENCES groups(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moduleId INTEGER,
        date TEXT,
        time TEXT,
        type TEXT,
        FOREIGN KEY(moduleId) REFERENCES modules(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE absences(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        studentId INTEGER,
        status TEXT,  -- present, absent, justified
        note TEXT,
        FOREIGN KEY(sessionId) REFERENCES sessions(id) ON DELETE CASCADE,
        FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE
      );
    ''');
  }
}
