import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/user.dart';

class UserTable {
  // Création de la table
  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER,
        massar TEXT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,  -- student, prof, coordinator, admin
        FOREIGN KEY (groupId) REFERENCES groups(id)
      )
    ''');
  }

  // Insérer un utilisateur
  static Future<int> insertUser(User user) async {
    final db = await DatabaseHelper().database;
    return await db.insert('users', user.toMap());
  }

  // Récupérer tous les utilisateurs
  static Future<List<User>> getAllUsers() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Récupérer un utilisateur par email (utile pour login)
  static Future<User?> getUserByEmail(String email) async {
    final db = await DatabaseHelper().database;
    final maps =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un utilisateur
  static Future<int> updateUser(User user) async {
    final db = await DatabaseHelper().database;
    return await db
        .update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Supprimer un utilisateur
  static Future<int> deleteUser(int id) async {
    final db = await DatabaseHelper().database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
