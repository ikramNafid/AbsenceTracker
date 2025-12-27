import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import 'student_stats_page.dart';

class StudentsListPage extends StatefulWidget {
  final int groupId;
  const StudentsListPage({super.key, required this.groupId});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  TextEditingController searchController = TextEditingController();

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
      filteredStudents = data;
    });
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = students
          .where((s) =>
              s['firstName'].toLowerCase().contains(query.toLowerCase()) ||
              s['lastName'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Étudiants")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: _filterStudents,
              decoration: const InputDecoration(
                labelText: "Rechercher un étudiant",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Card(
                  child: ListTile(
                    title:
                        Text("${student['firstName']} ${student['lastName']}"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudentStatsPage(studentId: student['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
