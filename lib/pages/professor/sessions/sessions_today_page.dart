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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodaySessions();
  }

  void _loadTodaySessions() async {
    setState(() => isLoading = true);
    final allSessions = await DatabaseHelper.instance.getSessionsToday();
    setState(() {
      sessions = allSessions;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Mes Séances du Jour",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header décoratif
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              "${sessions.length} séances prévues aujourd'hui",
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : sessions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final s = sessions[index];
                          return _buildSessionCard(s);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration:
              BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
          child: Icon(Icons.event_note, color: Colors.blue.shade700),
        ),
        title: Text(
          '${s['moduleName']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Groupe: ${s['groupName']}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('Heure: ${s['time']} • Type: ${s['type']}',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TakeAttendancePage(
                sessionId: s['id'],
                groupId: s['groupId'],
                title: "${s['moduleName']} - ${s['groupName']}",
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucune séance pour le moment",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

// --- ATTENDANCE PAGE (Version Modernisée) ---

class AttendancePage extends StatefulWidget {
  final int sessionId;
  final int groupId;
  const AttendancePage(
      {super.key, required this.sessionId, required this.groupId});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> students = [];
  Map<int, String> attendance = {};
  bool isLoading = true;

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
        isLoading = false;
      });
    } else {
      final studs =
          await DatabaseHelper.instance.getStudentsByGroup(widget.groupId);
      setState(() {
        students = studs;
        attendance = {for (var s in studs) s['id']: 'Présent'};
        isLoading = false;
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Présences enregistrées avec succès')),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV exporté vers: ${file.path}')));
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Table.fromTextArray(
        headers: ['Nom', 'Prénom', 'Status'],
        data: students
            .map((s) => [
                  s['firstName'] ?? '',
                  s['lastName'] ?? '',
                  attendance[s['id']] ?? 'Présent'
                ])
            .toList(),
      );
    }));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Feuille d'appel",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.picture_as_pdf), onPressed: _exportPDF),
          IconButton(
              icon: const Icon(Icons.file_download), onPressed: _exportCSV),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildQuickActions(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(attendance[s['id']]!)
                              .withOpacity(0.1),
                          child: Text(s['firstName'][0],
                              style: TextStyle(
                                  color:
                                      _getStatusColor(attendance[s['id']]!))),
                        ),
                        title: Text("${s['firstName']} ${s['lastName']}",
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: DropdownButton<String>(
                          value: attendance[s['id']],
                          underline: const SizedBox(),
                          items: _dropdownItems(),
                          onChanged: (v) =>
                              setState(() => attendance[s['id']] = v!),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: ElevatedButton(
          onPressed: _saveAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("ENREGISTRER L'APPEL",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickActionBtn(
              "Tout Présent", Colors.green, () => _markAll('Présent')),
          _quickActionBtn("Tout Absent", Colors.red, () => _markAll('Absent')),
        ],
      ),
    );
  }

  Widget _quickActionBtn(String label, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
          foregroundColor: color, side: BorderSide(color: color)),
      child: Text(label),
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems() {
    return const [
      DropdownMenuItem(
          value: 'Présent',
          child: Text('Présent', style: TextStyle(color: Colors.green))),
      DropdownMenuItem(
          value: 'Absent',
          child: Text('Absent', style: TextStyle(color: Colors.red))),
      DropdownMenuItem(
          value: 'Justifié',
          child: Text('Justifié', style: TextStyle(color: Colors.orange))),
    ];
  }

  Color _getStatusColor(String status) {
    if (status == 'Absent') return Colors.red;
    if (status == 'Justifié') return Colors.orange;
    return Colors.green;
  }
}
