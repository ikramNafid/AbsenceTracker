import 'package:flutter/material.dart';
import 'database/login_page.dart';

void main() {
  runApp(const MyApp());
}

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // initialisation
  runApp(const MyApp());
}
*/
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
/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dbPath = '...';

  @override
  void initState() {
    super.initState();
    getDatabasePath();
  }

  Future<void> getDatabasePath() async {
    // Chemin des bases de données SQLite
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mydatabase.db');

    // Crée la DB si elle n’existe pas
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
    );

    await db.close();

    setState(() {
      dbPath = path; // Affiche le chemin exact
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chemin DB SQLite')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Chemin de la DB :\n$dbPath',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
*/
