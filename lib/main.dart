import 'package:flutter/material.dart';
import 'core/db/database_helper.dart';
import 'inscription_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absence Tracker',
      home: const InscriptionPage(), // <-- on utilise maintenant la page
    );
  }
}
