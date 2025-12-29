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
  Map<int, String> attendanceStatus = {};
  Map<int, TextEditingController> noteControllers = {};
  bool isLoading = true;

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
        attendanceStatus[s['id']] = 'present';
        noteControllers[s['id']] = TextEditingController();
      }
      isLoading = false;
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
        const SnackBar(content: Text("✅ Absences enregistrées avec succès")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Feuille d'appel",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // En-tête incurvé avec détails de la séance
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.session['type']} - ${widget.session['date']}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Heure: ${widget.session['time']} • ${students.length} étudiants",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Barre d'actions rapides
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markAll('present'),
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.green),
                          label: const Text("Tout Présent",
                              style: TextStyle(color: Colors.green)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markAll('absent'),
                          icon: const Icon(Icons.highlight_off,
                              color: Colors.red),
                          label: const Text("Tout Absent",
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) =>
                        _buildStudentCard(students[index]),
                  ),
                ),

                // Bouton Enregistrer en bas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("ENREGISTRER LA FEUILLE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> s) {
    String status = attendanceStatus[s['id']]!;

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
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                  child: Text(s['firstName'][0],
                      style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "${s['firstName']} ${s['lastName']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // Sélecteur de statut simplifié
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: status,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    items: const [
                      DropdownMenuItem(
                          value: 'present',
                          child: Text('Présent',
                              style: TextStyle(
                                  color: Colors.green, fontSize: 13))),
                      DropdownMenuItem(
                          value: 'absent',
                          child: Text('Absent',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 13))),
                      DropdownMenuItem(
                          value: 'justified',
                          child: Text('Justifié',
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 13))),
                    ],
                    onChanged: (val) =>
                        setState(() => attendanceStatus[s['id']] = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteControllers[s['id']],
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Ajouter un commentaire ou motif...",
                prefixIcon: const Icon(Icons.edit_note, size: 20),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'absent') return Colors.red;
    if (status == 'justified') return Colors.orange;
    return Colors.green;
  }
}
