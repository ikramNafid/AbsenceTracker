import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/absence.dart';

class AbsenceTable {
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE absences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        studentId INTEGER,
        status TEXT,
        note TEXT,
        FOREIGN KEY (sessionId) REFERENCES sessions(id),
        FOREIGN KEY (studentId) REFERENCES users(id)
      )
    ''');
  }

  static Future<int> insertAbsence(Absence absence) async {
    final db = await DatabaseHelper().database;
    return await db.insert('absences', absence.toMap());
  }

  static Future<List<Absence>> getAllAbsences() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('absences');
    return List.generate(maps.length, (i) => Absence.fromMap(maps[i]));
  }
}
