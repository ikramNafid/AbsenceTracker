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
  final String title;

  const TakeAttendancePage({
    super.key,
    required this.sessionId,
    required this.groupId,
    required this.title,
  });

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  List<Map<String, dynamic>> students = [];
  Map<int, AttendanceStatus> attendance = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    final data =
        await DatabaseHelper.instance.getStudentsByGroup(widget.groupId);
    setState(() {
      students = data;
      for (var s in students) {
        attendance[s['id']] = AttendanceStatus.present;
      }
    });
  }

  void _markAll(AttendanceStatus status) {
    setState(() {
      for (var s in students) {
        attendance[s['id']] = status;
      }
    });
  }

  // --- LOGIQUE D'EXPORTATION ET PARTAGE ---
  Future<void> _exportAndShare(String format) async {
    final directory = await getTemporaryDirectory();
    final dateStr = DateTime.now().toString().substring(0, 10);
    final fileName = "Appel_${widget.title.replaceAll(' ', '_')}_$dateStr";
    String filePath = "";

    if (format == 'pdf') {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Rapport d'appel : ${widget.title}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text("Date : $dateStr"),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Nom', 'Prénom', 'Statut'],
                data: students
                    .map((s) => [
                          s['lastName'].toString().toUpperCase(),
                          s['firstName'],
                          attendance[s['id']].toString().split('.').last
                        ])
                    .toList(),
              ),
            ],
          ),
        ),
      );
      final file = File("${directory.path}/$fileName.pdf");
      await file.writeAsBytes(await pdf.save());
      filePath = file.path;
    } else {
      List<List<dynamic>> rows = [
        ["Nom", "Prénom", "Statut"]
      ];
      for (var s in students) {
        rows.add([
          s['lastName'],
          s['firstName'],
          attendance[s['id']].toString().split('.').last
        ]);
      }
      String csvData = const ListToCsvConverter().convert(rows);
      final file = File("${directory.path}/$fileName.csv");
      await file.writeAsString(csvData);
      filePath = file.path;
    }

    await Share.shareXFiles([XFile(filePath)],
        text: 'Rapport d\'appel - ${widget.title}');
  }

  void _saveAttendance() async {
    setState(() => _isSaving = true);
    final db = DatabaseHelper.instance;

    try {
      for (var s in students) {
        await db.insertAbsence({
          'sessionId': widget.sessionId,
          'studentId': s['id'],
          'status': attendance[s['id']].toString().split('.').last,
          'note': null,
        });
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Appel enregistré !"),
          content: const Text(
              "Voulez-vous exporter et partager la liste avant de quitter ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme dialogue
                Navigator.pop(context); // Retour accueil
              },
              child: const Text("NON, QUITTER"),
            ),
            IconButton(
              onPressed: () => _exportAndShare('csv'),
              icon: const Icon(Icons.description,
                  color: Colors.green), // CSV Icon
            ),
            ElevatedButton.icon(
              onPressed: () => _exportAndShare('pdf'),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("PDF"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildQuickActions(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                return _buildStudentCard(s, attendance[s['id']]!);
              },
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Text(
        "${students.length} étudiants à évaluer",
        style: const TextStyle(color: Colors.white70, fontSize: 15),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              label: const Text("Tous Présents",
                  style: TextStyle(color: Colors.green)),
              onPressed: () => _markAll(AttendanceStatus.present),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              label: const Text("Tous Absents",
                  style: TextStyle(color: Colors.red)),
              onPressed: () => _markAll(AttendanceStatus.absent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> s, AttendanceStatus status) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Text("${s['firstName'][0]}${s['lastName'][0]}",
                  style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold)),
            ),
            title: Text("${s['lastName'].toUpperCase()} ${s['firstName']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          SegmentedButton<AttendanceStatus>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: _getStatusColor(status),
              selectedForegroundColor: Colors.white,
            ),
            segments: const [
              ButtonSegment(
                  value: AttendanceStatus.present,
                  label: Text("Présent"),
                  icon: Icon(Icons.check, size: 16)),
              ButtonSegment(
                  value: AttendanceStatus.absent,
                  label: Text("Absent"),
                  icon: Icon(Icons.close, size: 16)),
              ButtonSegment(
                  value: AttendanceStatus.justified,
                  label: Text("Justifié"),
                  icon: Icon(Icons.info_outline, size: 16)),
            ],
            selected: {status},
            onSelectionChanged: (val) =>
                setState(() => attendance[s['id']] = val.first),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green.shade600;
      case AttendanceStatus.absent:
        return Colors.red.shade600;
      case AttendanceStatus.justified:
        return Colors.orange.shade600;
    }
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: _isSaving ? null : _saveAttendance,
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("VALIDER ET ENREGISTRER",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
