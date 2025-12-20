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

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT,
        lastName TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role INTEGER
      )
    ''');

    // 🔹 Utilisateurs par défaut
    await db.insert('users', {
      'firstName': 'Ikram',
      'lastName': 'Nafid',
      'email': 'ikram@ump.com',
      'password': '2003',
      'role': 1,
    });

    await db.insert('users', {
      'firstName': 'Mohammed',
      'lastName': 'Boudchiche',
      'email': 'mohammed@ump.com',
      'password': '1234',
      'role': 2,
    });

    await db.insert('users', {
      'firstName': 'Sofia',
      'lastName': 'Elhaj',
      'email': 'sofia@ump.com',
      'password': 'abcd',
      'role': 3,
    });

    await db.insert('users', {
      'firstName': 'Admin',
      'lastName': 'Admin',
      'email': 'admin@ump.com',
      'password': 'admin',
      'role': 4,
    });
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }
}
