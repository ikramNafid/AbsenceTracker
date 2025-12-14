import 'package:flutter/foundation.dart';
import '../models/group_model.dart';
import '../core/db/database_helper.dart';

class GroupProvider extends ChangeNotifier {
  final _dbHelper = DatabaseHelper.instance;
  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;

  Future<void> fetchGroups() async {
    final db = await _dbHelper.database;
    final res = await db.query('groups', orderBy: 'name ASC');
    _groups = res.map((e) => GroupModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<int> addGroup(GroupModel group) async {
    final db = await _dbHelper.database;
    final id = await db.insert('groups', group.toMap());
    await fetchGroups();
    return id;
  }

  Future<void> updateGroup(GroupModel group) async {
    final db = await _dbHelper.database;
    await db.update(
      'groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
    await fetchGroups();
  }

  Future<void> deleteGroup(int id) async {
    final db = await _dbHelper.database;
    await db.delete('groups', where: 'id = ?', whereArgs: [id]);
    await fetchGroups();
  }

  Future<List<GroupModel>> searchGroups(String query) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'groups',
      where: 'name LIKE ? OR filiere LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return res.map((e) => GroupModel.fromMap(e)).toList();
  }
}
