// ------------------- StudentsByGroupPage -------------------
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class StudentsByGroupPage extends StatefulWidget {
  final int groupId;
  final String groupName;

  const StudentsByGroupPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<StudentsByGroupPage> createState() => _StudentsByGroupPageState();
}

class _StudentsByGroupPageState extends State<StudentsByGroupPage> {
  List<Map<String, dynamic>> students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => loading = true);
    final data =
        await DatabaseHelper.instance.getStudentsByGroup(widget.groupId);
    setState(() {
      students = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Étudiants du groupe ${widget.groupName}"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(
                  child: Text("Aucun étudiant trouvé dans ce groupe"),
                )
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(
                            "${student['firstName']} ${student['lastName']}"),
                        subtitle: Text(student['email'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
