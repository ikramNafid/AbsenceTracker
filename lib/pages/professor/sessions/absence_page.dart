import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class AbsencePage extends StatefulWidget {
  final int sessionId;
  final String moduleName;
  final String groupName;

  const AbsencePage({
    super.key,
    required this.sessionId,
    required this.moduleName,
    required this.groupName,
  });

  @override
  State<AbsencePage> createState() => _AbsencePageState();
}

class _AbsencePageState extends State<AbsencePage> {
  List<Map<String, dynamic>> students = [];
  Map<int, String> attendance = {}; // studentId -> 'P', 'A', or 'R'
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // 1. Charger les détails de la session
    final session =
        await DatabaseHelper.instance.getSessionById(widget.sessionId);

    // Vérification de sécurité : si la session est null, on arrête ou on affiche une erreur
    if (session == null) {
      setState(() => isLoading = false);
      return;
    }

    // Utilisation sécurisée après le check de nullité
    final int groupId = session['groupId'];

    // 2. Charger les étudiants du groupe
    final studentData =
        await DatabaseHelper.instance.getStudentsByGroup(groupId);

    // 3. Charger les absences déjà enregistrées
    final existingAbsences =
        await DatabaseHelper.instance.getAbsencesBySession(widget.sessionId);

    setState(() {
      students = studentData;
      for (var abs in existingAbsences) {
        attendance[abs['studentId']] = abs['status'];
      }
      isLoading = false;
    });
  }

  void _saveAttendance() async {
    for (var student in students) {
      final studentId = student['id'];
      await DatabaseHelper.instance.insertAbsence({
        'sessionId': widget.sessionId,
        'studentId': studentId,
        'status': attendance[studentId] ?? 'P', // Par défaut Présent
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appel enregistré avec succès !")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.moduleName} - ${widget.groupName}"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAttendance)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final sId = student['id'];
                String status = attendance[sId] ?? 'P';

                return ListTile(
                  title: Text("${student['firstName']} ${student['lastName']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusButton(sId, 'P', Colors.green, status == 'P'),
                      _statusButton(sId, 'A', Colors.red, status == 'A'),
                      _statusButton(sId, 'R', Colors.orange, status == 'R'),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAttendance,
        label: const Text("Valider l'appel"),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Widget _statusButton(
      int studentId, String code, Color color, bool isSelected) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Text(code,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      ),
      onPressed: () => setState(() => attendance[studentId] = code),
    );
  }
}
