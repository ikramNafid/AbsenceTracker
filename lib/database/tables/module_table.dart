import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/module.dart';

class ModuleTable {
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE modules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        semester TEXT,
        groupId INTEGER,
        FOREIGN KEY (groupId) REFERENCES groups(id)
      )
    ''');
  }

  static Future<int> insertModule(Module module) async {
    final db = await DatabaseHelper().database;
    return await db.insert('modules', module.toMap());
  }

  static Future<List<Module>> getAllModules() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('modules');
    return List.generate(maps.length, (i) => Module.fromMap(maps[i]));
  }
}
