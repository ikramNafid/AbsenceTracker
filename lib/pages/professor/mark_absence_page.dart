import 'package:flutter/material.dart';

class MarkAbsence extends StatelessWidget {
  const MarkAbsence({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de séances du jour simulées
    final sessions = [
      {
        'group': 'Groupe A',
        'module': 'Mathématiques',
        'time': '08:30 - 10:00',
        'students': ['Ali', 'Sara', 'Omar']
      },
      {
        'group': 'Groupe B',
        'module': 'Informatique',
        'time': '10:30 - 12:00',
        'students': ['Lina', 'Khalid', 'Nora']
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Séances du jour')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final s = sessions[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${s['module']} • ${s['group']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Heure : ${s['time']}'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Naviguer vers la page de marquage des absences
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => StudentAbsencePage(
                                    groupName: s['group'] as String,
                                    students: List<String>.from(
                                        s['students'] as List))),
                          );
                        },
                        child: const Text('Liste des étudiants'),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- Page pour marquer les absences d’un groupe ----------------
class StudentAbsencePage extends StatefulWidget {
  final String groupName;
  final List<String> students;

  const StudentAbsencePage(
      {super.key, required this.groupName, required this.students});

  @override
  State<StudentAbsencePage> createState() => _StudentAbsencePageState();
}

enum AbsenceStatus { present, absent, justified }

class _StudentAbsencePageState extends State<StudentAbsencePage> {
  late List<Map<String, dynamic>> studentData;

  @override
  void initState() {
    super.initState();
    studentData = widget.students
        .map((name) =>
            {'name': name, 'status': AbsenceStatus.present, 'comment': ''})
        .toList();
  }

  void markAll(AbsenceStatus status) {
    setState(() {
      for (var s in studentData) {
        s['status'] = status;
      }
    });
  }

  void saveAbsences() {
    for (var s in studentData) {
      print('${s['name']} : ${s['status']} ${s['comment']}');
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Absences enregistrées !')));
  }

  Future<String?> _showCommentDialog(String studentName) async {
    String comment = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Justification - $studentName'),
          content: TextField(
            onChanged: (value) => comment = value,
            decoration: const InputDecoration(hintText: 'Motif de l\'absence'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler')),
            TextButton(
                onPressed: () => Navigator.pop(context, comment),
                child: const Text('OK')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Marquer absences - ${widget.groupName}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () => markAll(AbsenceStatus.present),
                    child: const Text('Tout Présent')),
                ElevatedButton(
                    onPressed: () => markAll(AbsenceStatus.absent),
                    child: const Text('Tout Absent')),
                ElevatedButton(
                    onPressed: saveAbsences, child: const Text('Enregistrer')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: studentData.length,
              itemBuilder: (context, index) {
                final student = studentData[index];
                return Card(
                  child: ListTile(
                    title: Text(student['name']),
                    subtitle: student['status'] == AbsenceStatus.justified
                        ? Text('Justifié : ${student['comment']}')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              setState(() =>
                                  student['status'] = AbsenceStatus.present);
                            }),
                        IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() =>
                                  student['status'] = AbsenceStatus.absent);
                            }),
                        IconButton(
                            icon:
                                const Icon(Icons.circle, color: Colors.orange),
                            onPressed: () async {
                              String? comment =
                                  await _showCommentDialog(student['name']);
                              if (comment != null) {
                                setState(() {
                                  student['status'] = AbsenceStatus.justified;
                                  student['comment'] = comment;
                                });
                              }
                            }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
