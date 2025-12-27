import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AssignedStudentsPage extends StatefulWidget {
  final int filiereId;

  const AssignedStudentsPage({Key? key, required this.filiereId})
      : super(key: key);

  @override
  State<AssignedStudentsPage> createState() => _AssignedStudentsPageState();
}

class _AssignedStudentsPageState extends State<AssignedStudentsPage> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final stus =
        await DatabaseHelper.instance.getStudentsByFiliere(widget.filiereId);
    setState(() {
      students = stus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Étudiants assignés"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: students.isEmpty
          ? const Center(child: Text("Aucun étudiant assigné"))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title:
                        Text('${student['firstName']} ${student['lastName']}'),
                    subtitle: Text(student['email'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
