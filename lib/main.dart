import 'package:absence_tracker/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import './database/database_helper.dart';
import './pages/professor/prof_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Récupérer la DB et insérer les données test
  await DatabaseHelper.instance.database;
  // await DatabaseHelper.instance.insertTestData(db);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absence Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
