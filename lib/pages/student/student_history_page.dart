import 'package:absence_tracker/database/database_helper.dart';
import 'package:absence_tracker/models/absence_model.dart';
import 'package:absence_tracker/widgets/absence_tile.dart';
import 'package:flutter/material.dart';

class StudentHistoryPage extends StatefulWidget {
  final int studentId;
  const StudentHistoryPage({super.key, required this.studentId});

  @override
  State<StudentHistoryPage> createState()=> _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage>{

  final db = DatabaseHelper.instance;
  List<Absence> absences =[];
  @override
  void initState(){
    super.initState();
    loadAbsences();
  }
  void loadAbsences() async{
    final data = await db.getAbsencesByStudent(widget.studentId);
    setState((){
      absences = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes absences"),
      ),
      body: absences.isEmpty
          ? Center(child: Text("Aucune absence"))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: absences.length,
              itemBuilder: (context, index) {
                return AbsenceTile(absence: absences[index]);
              },
            ),
    );

  }
}
