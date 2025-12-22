import 'package:absence_tracker/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AbsenceService {
  Future<void> saveAbsence({
    required int sessionId,
    required int studentId,
    required String status,
    String? note,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'absences',
      {
        'sessionId': sessionId,
        'studentId': studentId,
        'status': status,
        'note': note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
