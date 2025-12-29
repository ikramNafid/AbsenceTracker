import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:csv/csv.dart';
import '../../database/database_helper.dart';

enum AttendanceStatus { present, absent, justified }

class TakeAttendancePage extends StatefulWidget {
  final int sessionId;
  final int groupId;
  final String title; // ✅ AJOUT

  const TakeAttendancePage({
    super.key,
    required this.sessionId,
    required this.groupId,
    required this.title, // ✅ AJOUT
  });

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  List<Map<String, dynamic>> students = [];
  Map<int, bool> presence = {}; // studentId -> présent ou non
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final data =
        await DatabaseHelper.instance.getStudentsByGroup(widget.groupId);

    setState(() {
      students = data;
      for (var s in students) {
        presence[s['id']] = true; // présent par défaut
      }
      loading = false;
    });
  }

  Future<void> _saveAttendance() async {
    for (var s in students) {
      await DatabaseHelper.instance.insertAbsence({
        'sessionId': widget.sessionId,
        'studentId': s['id'],
        'status': presence[s['id']]! ? 'present' : 'absent',
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appel enregistré avec succès")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faire l'appel")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return CheckboxListTile(
                        title: Text("${s['lastName']} ${s['firstName']}"),
                        value: presence[s['id']],
                        onChanged: (val) {
                          setState(() {
                            presence[s['id']] = val!;
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Enregistrer l'appel"),
                    onPressed: _saveAttendance,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                  ),
                )
              ],
            ),
    );
  }
}
