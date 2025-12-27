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

  // --- LOGIQUE D'EXPORTATION ---
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
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Nom', 'Prenom', 'Statut'],
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
        ["Nom", "Prenom", "Statut"]
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

  // --- ENREGISTREMENT ET DIALOGUE ---
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

      // Afficher le dialogue d'exportation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Appel enregistré !"),
          content:
              const Text("Voulez-vous exporter la liste avant de quitter ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme le dialogue
                Navigator.pop(context); // Retour à l'accueil
              },
              child: const Text("Non, quitter"),
            ),
            TextButton(
              onPressed: () => _exportAndShare('csv'),
              child: const Text("CSV"),
            ),
            ElevatedButton(
              onPressed: () => _exportAndShare('pdf'),
              child: const Text("PDF"),
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
      appBar: AppBar(title: Text(widget.title), elevation: 0),
      body: Column(
        children: [
          _buildQuickActions(),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                final status = attendance[s['id']];
                return _buildStudentCard(s, status!);
              },
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Tous Présents"),
              onPressed: () => _markAll(AttendanceStatus.present),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text("Tous Absents"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => _markAll(AttendanceStatus.absent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> s, AttendanceStatus status) {
    Color bgColor = Colors.white;
    if (status == AttendanceStatus.absent) bgColor = Colors.red.shade50;
    if (status == AttendanceStatus.justified) bgColor = Colors.orange.shade50;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: bgColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade800,
                child: Text("${s['firstName'][0]}${s['lastName'][0]}",
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              title: Text("${s['lastName'].toUpperCase()} ${s['firstName']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            SegmentedButton<AttendanceStatus>(
              segments: const [
                ButtonSegment(
                    value: AttendanceStatus.present,
                    label: Text("Présent"),
                    icon: Icon(Icons.check)),
                ButtonSegment(
                    value: AttendanceStatus.absent,
                    label: Text("Absent"),
                    icon: Icon(Icons.close)),
                ButtonSegment(
                    value: AttendanceStatus.justified,
                    label: Text("Justifié"),
                    icon: Icon(Icons.info_outline)),
              ],
              selected: {status},
              onSelectionChanged: (val) =>
                  setState(() => attendance[s['id']] = val.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16)),
        onPressed: _isSaving ? null : _saveAttendance,
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("VALIDER L'APPEL",
                style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
