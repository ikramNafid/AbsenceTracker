import 'package:flutter/material.dart';
import 'database/login_page.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ⚡ Nécessaire pour async

  final dbHelper = DatabaseHelper.instance;

  // Insérer des modules, groupes, et séances par défaut
  await dbHelper.insertDefaultSessions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
