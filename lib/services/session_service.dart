import 'package:sqflite/sqflite.dart';
import 'package:absence_tracker/database/database_helper.dart';

class SessionService {
  Future<List<Map<String, dynamic>>> getSessionsByGroup(int groupId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT s.*, m.name AS moduleName
      FROM sessions s
      JOIN modules m ON s.moduleId = m.id
      WHERE m.groupId = ?
      ORDER BY s.date DESC
    ''', [groupId]);

    return result;
  }
}
