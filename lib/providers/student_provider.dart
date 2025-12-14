import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../core/db/database_helper.dart';

class StudentProvider extends ChangeNotifier {
  final _dbHelper = DatabaseHelper.instance;
  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  Future<void> fetchStudents({int? groupId}) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'students',
      where: groupId != null ? 'groupId = ?' : null,
      whereArgs: groupId != null ? [groupId] : null,
      orderBy: 'lastName ASC, firstName ASC',
    );
    _students = res.map((e) => StudentModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<int> addStudent(StudentModel s) async {
    final db = await _dbHelper.database;
    final id = await db.insert('students', s.toMap());
    await fetchStudents(groupId: s.groupId);
    return id;
  }

  Future<void> updateStudent(StudentModel s) async {
    final db = await _dbHelper.database;
    await db.update('students', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
    await fetchStudents(groupId: s.groupId);
  }

  Future<void> deleteStudent(int id, {int? groupId}) async {
    final db = await _dbHelper.database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
    await fetchStudents(groupId: groupId);
  }

  Future<List<StudentModel>> search(String query, {int? groupId}) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'students',
      where:
          (groupId != null ? 'groupId = ? AND ' : '') +
          '(firstName LIKE ? OR lastName LIKE ? OR massar LIKE ?)',
      whereArgs: groupId != null
          ? [groupId, '%$query%', '%$query%', '%$query%']
          : ['%$query%', '%$query%', '%$query%'],
      orderBy: 'lastName ASC',
    );
    return res.map((e) => StudentModel.fromMap(e)).toList();
  }
}
