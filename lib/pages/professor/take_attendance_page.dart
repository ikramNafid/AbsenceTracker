import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class TakeAttendancePage extends StatefulWidget {
  final int sessionId;
  const TakeAttendancePage({super.key, required this.sessionId});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  List<Map<String, dynamic>> students = [];
  Map<int, String> statusMap = {}; // studentId -> "Present" / "Absent"

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // Récupérer session
    final session =
        await DatabaseHelper.instance.getSessionById(widget.sessionId);

    // Ici on suppose que chaque séance est liée à un seul groupe via module_groups
    final moduleId = session['moduleId'] as int;
    final groups = await DatabaseHelper.instance.getGroupsByModule(moduleId);

    if (groups.isEmpty) return;
    final groupId = groups.first['id'] as int;

    final studentList =
        await DatabaseHelper.instance.getStudentsByGroup(groupId);
    setState(() {
      students = studentList;
      // Initialiser le status par défaut
      for (var s in students) {
        statusMap[s['id'] as int] = 'Absent';
      }
    });
  }

  Future<void> _saveAttendance() async {
    for (var student in students) {
      final studentId = student['id'] as int;
      final status = statusMap[studentId] ?? 'Absent';
      await DatabaseHelper.instance.insertAbsence({
        'sessionId': widget.sessionId,
        'studentId': studentId,
        'status': status,
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Absences enregistrées avec succès !')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marquer les absences")),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final studentId = student['id'] as int;
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title:
                        Text('${student['firstName']} ${student['lastName']}'),
                    trailing: DropdownButton<String>(
                      value: statusMap[studentId],
                      items: const [
                        DropdownMenuItem(
                            value: 'Present', child: Text('Présent')),
                        DropdownMenuItem(
                            value: 'Absent', child: Text('Absent')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          statusMap[studentId] = val!;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _saveAttendance,
          child: const Text('Enregistrer les absences'),
        ),
      ),
    );
  }
}
