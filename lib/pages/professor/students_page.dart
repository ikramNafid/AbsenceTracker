import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class StudentsPage extends StatefulWidget {
  final int groupId;
  final String groupName;

  const StudentsPage(
      {super.key, required this.groupId, required this.groupName});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    final data =
        await DatabaseHelper.instance.getStudentsByGroup(widget.groupId);
    setState(() {
      students = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Étudiants - ${widget.groupName}"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // En-tête avec le nombre d'étudiants
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.indigo.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.indigo),
                      const SizedBox(width: 10),
                      Text(
                        "${students.length} étudiants inscrits",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
                // Liste des étudiants
                Expanded(
                  child: students.isEmpty
                      ? const Center(
                          child: Text("Aucun étudiant dans ce groupe"))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: students.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(
                                  student['firstName'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.indigo),
                                ),
                              ),
                              title: Text(
                                "${student['firstName']} ${student['lastName']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(student['email'] ?? "Pas d'email"),
                              trailing: const Icon(Icons.info_outline,
                                  color: Colors.grey, size: 20),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
