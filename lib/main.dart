import 'package:absence_tracker/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:absence_tracker/database/database_helper.dart';
// import './pages/professor/prof_home.dart'; // Import inutilisé ici, peut être supprimé

void main() async {
  // Indispensable pour l'initialisation asynchrone dans le main
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données au démarrage
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absence Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Recommandé pour les nouvelles versions de Flutter
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
