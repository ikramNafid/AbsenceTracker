import 'package:absence_tracker/database/database_helper.dart';
import 'package:absence_tracker/models/absence_model.dart';
import 'package:absence_tracker/widgets/absence_tile.dart';
import 'package:flutter/material.dart';

class StudentHistoryPage extends StatefulWidget {
  final int studentId;
  const StudentHistoryPage({super.key, required this.studentId});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

// ... imports ...

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  final db = DatabaseHelper.instance;
  List<Absence> absences = [];

  @override
  void initState() {
    super.initState();
    loadAbsences();
  }

  void loadAbsences() async {
    // On appelle la méthode du DatabaseHelper
    final data = await db.getAbsencesByStudent(widget.studentId);
    setState(() {
      absences = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes absences")),
      body: absences.isEmpty
          ? const Center(child: Text("Aucune absence"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: absences.length,
              itemBuilder: (context, index) =>
                  AbsenceTile(absence: absences[index]),
            ),
    );
  }
}
