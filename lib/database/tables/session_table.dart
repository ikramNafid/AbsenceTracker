import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/session.dart';

class SessionTable {
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moduleId INTEGER,
        date TEXT NOT NULL,
        time TEXT,
        type TEXT,
        FOREIGN KEY (moduleId) REFERENCES modules(id)
      )
    ''');
  }

  static Future<int> insertSession(Session session) async {
    final db = await DatabaseHelper().database;
    return await db.insert('sessions', session.toMap());
  }

  static Future<List<Session>> getAllSessions() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('sessions');
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }
}
