import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class AttendanceSessionPage extends StatefulWidget {
  final Map<String, dynamic> session;

  const AttendanceSessionPage({super.key, required this.session});

  @override
  State<AttendanceSessionPage> createState() => _AttendanceSessionPageState();
}

class _AttendanceSessionPageState extends State<AttendanceSessionPage> {
  List<Map<String, dynamic>> students = [];
  Map<int, String> attendanceStatus = {}; // studentId -> status
  Map<int, TextEditingController> noteControllers = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    final groupId = widget.session['groupId'];
    final data = await DatabaseHelper.instance.getStudentsByGroup(groupId);

    setState(() {
      students = data;
      for (var s in students) {
        attendanceStatus[s['id']] = 'present'; // par défaut présent
        noteControllers[s['id']] = TextEditingController();
      }
    });
  }

  void _markAll(String status) {
    setState(() {
      for (var s in students) {
        attendanceStatus[s['id']] = status;
      }
    });
  }

  void _saveAttendance() async {
    for (var s in students) {
      await DatabaseHelper.instance.insertAbsence({
        'sessionId': widget.session['id'],
        'studentId': s['id'],
        'status': attendanceStatus[s['id']],
        'note': noteControllers[s['id']]?.text ?? '',
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Absences enregistrées avec succès")));
    Navigator.pop(context);
  }

  Widget _buildStudentCard(Map<String, dynamic> s) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${s['firstName']} ${s['lastName']}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                DropdownButton<String>(
                  value: attendanceStatus[s['id']],
                  items: const [
                    DropdownMenuItem(
                      value: 'present',
                      child: Text('✓ Présent'),
                    ),
                    DropdownMenuItem(
                      value: 'absent',
                      child: Text('✗ Absent'),
                    ),
                    DropdownMenuItem(
                      value: 'justified',
                      child: Text('○ Justifié'),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      attendanceStatus[s['id']] = val!;
                    });
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: noteControllers[s['id']],
                    decoration: const InputDecoration(
                      hintText: "Commentaire / justification",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Séance: ${widget.session['type']} - ${widget.session['date']} ${widget.session['time']}"),
      ),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Actions rapides
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () => _markAll('present'),
                          child: const Text("Tout présent")),
                      ElevatedButton(
                          onPressed: () => _markAll('absent'),
                          child: const Text("Tout absent")),
                    ],
                  ),
                ),
                const Divider(),
                // Liste des étudiants
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) =>
                        _buildStudentCard(students[index]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: _saveAttendance,
                      child: const Text("Enregistrer")),
                ),
              ],
            ),
    );
  }
}
