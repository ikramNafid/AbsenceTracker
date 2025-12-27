import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class ListeEtudiantsParFilieres extends StatefulWidget {
  const ListeEtudiantsParFilieres({super.key});

  @override
  State<ListeEtudiantsParFilieres> createState() =>
      _ListeEtudiantsParFilieresState();
}

class _ListeEtudiantsParFilieresState extends State<ListeEtudiantsParFilieres> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  // 🔹 Charger tous les étudiants avec leur filière
  Future<void> _loadStudents() async {
    final stus = await DatabaseHelper.instance.getStudents();
    setState(() {
      students = stus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des étudiants par filières'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        student['firstName'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title:
                        Text('${student['firstName']} ${student['lastName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email : ${student['email'] ?? '-'}'),
                        Text('Filière : ${student['filiere'] ?? '-'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
