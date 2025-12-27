import 'package:flutter/material.dart';
import 'package:absence_tracker/database/database_helper.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:absence_tracker/pages/professor/take_attendance_page.dart';

class SessionsTodayPage extends StatefulWidget {
  const SessionsTodayPage({super.key});

  @override
  State<SessionsTodayPage> createState() => _SessionsTodayPageState();
}

class _SessionsTodayPageState extends State<SessionsTodayPage> {
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadTodaySessions();
  }

  void _loadTodaySessions() async {
    final allSessions = await DatabaseHelper.instance.getSessionsToday();
    setState(() {
      sessions = allSessions;
    });
  }

  void _openAttendance(int sessionId, int groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendancePage(
          sessionId: sessionId,
          groupId: groupId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Séances du jour")),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final s = sessions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('${s['moduleName']} - ${s['groupName']}'),
              subtitle: Text('Type: ${s['type']} - Heure: ${s['time']}'),
              trailing: const Icon(Icons.arrow_forward),
              // Dans sessions_today_page.dart
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TakeAttendancePage(
                      sessionId: s['id'],
                      groupId: s['groupId'],
                      title:
                          "${s['moduleName']} - ${s['groupName']}", // Titre combiné
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  final int sessionId;
  final int groupId;
  const AttendancePage({
    super.key,
    required this.sessionId,
    required this.groupId,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> students = [];
  Map<int, String> attendance = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    final absences =
        await DatabaseHelper.instance.getAbsencesBySession(widget.sessionId);

    if (absences.isNotEmpty) {
      setState(() {
        students = absences;
        attendance = {for (var a in absences) a['studentId']: a['status']};
      });
    } else {
      final studs =
          await DatabaseHelper.instance.getStudentsByGroup(widget.groupId);

      setState(() {
        students = studs;
        attendance = {for (var s in studs) s['id']: 'Présent'};
      });
    }
  }

  void _markAll(String status) {
    setState(() {
      for (var s in students) {
        attendance[s['id']] = status;
      }
    });
  }

  void _saveAttendance() async {
    for (var s in students) {
      await DatabaseHelper.instance.insertAbsence({
        'sessionId': widget.sessionId,
        'studentId': s['id'],
        'status': attendance[s['id']],
        'note': ''
      });
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Présences enregistrées')));
  }

  Future<void> _exportCSV() async {
    List<List<String>> rows = [
      ['Nom', 'Prénom', 'Status']
    ];
    for (var s in students) {
      rows.add([
        s['firstName'] ?? '',
        s['lastName'] ?? '',
        attendance[s['id']] ?? 'Présent'
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/absences_session_${widget.sessionId}.csv');
    await file.writeAsString(csv);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('CSV exporté: ${file.path}')));
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Table.fromTextArray(
            headers: ['Nom', 'Prénom', 'Status'],
            data: students.map((s) {
              return [
                s['firstName'] ?? '',
                s['lastName'] ?? '',
                attendance[s['id']] ?? 'Présent'
              ];
            }).toList(),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marquer les absences")),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final s = students[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              title: Text('${s['firstName']} ${s['lastName']}'),
              trailing: DropdownButton<String>(
                value: attendance[s['id']],
                items: const [
                  DropdownMenuItem(value: 'Présent', child: Text('✓ Présent')),
                  DropdownMenuItem(value: 'Absent', child: Text('✗ Absent')),
                  DropdownMenuItem(
                      value: 'Justifié', child: Text('○ Justifié')),
                ],
                onChanged: (v) {
                  setState(() {
                    attendance[s['id']] = v!;
                  });
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Card(
        margin: const EdgeInsets.all(8),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              ElevatedButton.icon(
                onPressed: () => _markAll('Présent'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Tout présent'),
              ),
              ElevatedButton.icon(
                onPressed: () => _markAll('Absent'),
                icon: const Icon(Icons.cancel),
                label: const Text('Tout absent'),
              ),
              ElevatedButton.icon(
                onPressed: _saveAttendance,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
              ElevatedButton.icon(
                onPressed: _exportCSV,
                icon: const Icon(Icons.file_copy),
                label: const Text('CSV'),
              ),
              ElevatedButton.icon(
                onPressed: _exportPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
