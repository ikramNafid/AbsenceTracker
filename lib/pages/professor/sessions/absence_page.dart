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
    final session =
        await DatabaseHelper.instance.getSessionById(widget.sessionId);
    final studentData =
        await DatabaseHelper.instance.getStudentsByGroup(session['groupId']);
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
        'status': attendance[studentId] ?? 'P',
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Appel enregistré avec succès !"),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Feuille de Présence",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () => _markAll('P'),
              tooltip: "Tout présent"),
        ],
      ),
      body: Column(
        children: [
          // En-tête incurvé avec infos séance
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
                Text(widget.moduleName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Groupe : ${widget.groupName} • ${students.length} élèves",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final sId = student['id'];
                      String status = attendance[sId] ?? 'P';
                      return _buildStudentListItem(student, sId, status);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAttendance,
        backgroundColor: Colors.blue.shade700,
        label: const Text("VALIDER L'APPEL",
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.check_circle),
      ),
    );
  }

  Widget _buildStudentListItem(
      Map<String, dynamic> student, int sId, String status) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          "${student['firstName']} ${student['lastName']}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: const Text("Cliquer pour changer le statut",
            style: TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusToggleItem(sId, 'P', Colors.green, status == 'P'),
            _statusToggleItem(sId, 'A', Colors.red, status == 'A'),
            _statusToggleItem(sId, 'R', Colors.orange, status == 'R'),
          ],
        ),
      ),
    );
  }

  Widget _statusToggleItem(
      int studentId, String code, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => attendance[studentId] = code),
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          code,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _markAll(String status) {
    setState(() {
      for (var s in students) {
        attendance[s['id']] = status;
      }
    });
  }
}
