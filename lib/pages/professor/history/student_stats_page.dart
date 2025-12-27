import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class StudentStatsPage extends StatefulWidget {
  final int studentId;
  const StudentStatsPage({super.key, required this.studentId});

  @override
  State<StudentStatsPage> createState() => _StudentStatsPageState();
}

class _StudentStatsPageState extends State<StudentStatsPage> {
  List<Map<String, dynamic>> absences = [];
  String studentName = "";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final db = DatabaseHelper.instance;
    final studentData =
        await db.getStudentsByGroup(0); // récupère tous et filtrer si besoin
    final student = studentData.firstWhere((s) => s['id'] == widget.studentId);
    studentName = "${student['firstName']} ${student['lastName']}";

    final absData = await db.getAbsencesBySession(
        0); // à remplacer par toutes les séances si besoin
    setState(() {
      absences =
          absData.where((a) => a['studentId'] == widget.studentId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalAbs = absences.length;
    int justified = absences.where((a) => a['status'] == "Justifié").length;
    int nonJustified = absences.where((a) => a['status'] == "Absent").length;
    int present = absences.where((a) => a['status'] == "Présent").length;

    Color indicator = totalAbs > 5
        ? Colors.red
        : totalAbs > 2
            ? Colors.orange
            : Colors.green;

    return Scaffold(
      appBar: AppBar(title: Text("Statistiques de $studentName")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total d’absences: $totalAbs", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Présences: $present", style: TextStyle(fontSize: 16)),
            Text("Absences non justifiées: $nonJustified",
                style: TextStyle(fontSize: 16)),
            Text("Absences justifiées: $justified",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Indicateur: "),
                Container(width: 20, height: 20, color: indicator),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
