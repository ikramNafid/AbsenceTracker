import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class DistributeStudentsPage extends StatefulWidget {
  const DistributeStudentsPage({super.key});

  @override
  State<DistributeStudentsPage> createState() => _DistributeStudentsPageState();
}

class _DistributeStudentsPageState extends State<DistributeStudentsPage> {
  int? selectedFiliereId;
  List<Map<String, dynamic>> filieres = [];
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    loadFilieres();
  }

  Future<void> loadFilieres() async {
    final data = await DatabaseHelper.instance.getFilieres();
    setState(() {
      filieres = data;
    });
  }

  Future<void> loadGroupsAndStudents(int filiereId) async {
    final g = await DatabaseHelper.instance.getGroupsByFiliere(filiereId);
    final s = await DatabaseHelper.instance.getStudentsByFiliere(filiereId);
    setState(() {
      selectedFiliereId = filiereId;
      groups = g;
      students = s;
    });
  }

  Future<void> assignStudentToGroup(int studentId, int groupId) async {
    await DatabaseHelper.instance
        .updateStudent(studentId, {'groupId': groupId});
    // Recharge les étudiants
    if (selectedFiliereId != null) {
      loadGroupsAndStudents(selectedFiliereId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Répartir les étudiants"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Dropdown pour choisir une filière
            DropdownButton<int>(
              hint: const Text("Choisir une filière"),
              value: selectedFiliereId,
              items: filieres.map<DropdownMenuItem<int>>((f) {
                return DropdownMenuItem<int>(
                  value: f['id'] as int,
                  child: Text(f['nom']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) loadGroupsAndStudents(value);
              },
            ),
            const SizedBox(height: 20),
            // 🔹 Liste des groupes
            if (groups.isNotEmpty) ...[
              const Text("Groupes disponibles:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children:
                    groups.map((g) => Chip(label: Text(g['name']))).toList(),
              ),
              const SizedBox(height: 20),
            ],
            // 🔹 Liste des étudiants
            if (students.isNotEmpty) ...[
              const Text("Étudiants:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                            "${student['firstName']} ${student['lastName']}"),
                        subtitle: Text("Email: ${student['email']}"),
                        trailing: DropdownButton<int>(
                          hint: const Text("Groupe"),
                          value: student['groupId'] as int?,
                          items: groups.map<DropdownMenuItem<int>>((g) {
                            return DropdownMenuItem<int>(
                              value: g['id'] as int,
                              child: Text(g['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null)
                              assignStudentToGroup(student['id'] as int, value);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
