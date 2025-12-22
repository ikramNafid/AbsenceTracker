import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/fliliere.dart';

class FiliereTable {
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE filieres (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT UNIQUE,
        description TEXT
      )
    ''');
  }

  static Future<int> insertFiliere(Filiere filiere) async {
    final db = await DatabaseHelper().database;
    return await db.insert('filieres', filiere.toMap());
  }

  static Future<List<Filiere>> getAllFilieres() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('filieres');
    return List.generate(maps.length, (i) => Filiere.fromMap(maps[i]));
  }
}
