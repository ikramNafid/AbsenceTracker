import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/group.dart';

class GroupTable {
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        filiereId INTEGER,
        FOREIGN KEY (filiereId) REFERENCES filieres(id)
      )
    ''');
  }

  static Future<int> insertGroup(Group group) async {
    final db = await DatabaseHelper().database;
    return await db.insert('groups', group.toMap());
  }

  static Future<List<Group>> getAllGroups() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('groups');
    return List.generate(maps.length, (i) => Group.fromMap(maps[i]));
  }
}
