import 'package:flutter/material.dart';

class StudentHistory extends StatelessWidget {
  final String studentName;

  const StudentHistory({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    // Exemple de données simulées
    final totalAbsences = 8;
    final absencesByModule = {
      'Mathématiques': 3,
      'Informatique': 5,
    };
    final sessionDates = [
      {'date': '12/12/2025', 'module': 'Mathématiques', 'status': 'Absent'},
      {'date': '13/12/2025', 'module': 'Informatique', 'status': 'Justifié'},
      {'date': '14/12/2025', 'module': 'Informatique', 'status': 'Absent'},
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case 'Présent':
          return Colors.green;
        case 'Justifié':
          return Colors.orange;
        case 'Absent':
        default:
          return Colors.red;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Historique - $studentName')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ Total absences
            Card(
              child: ListTile(
                title: Text(studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Total absences : $totalAbsences'),
              ),
            ),
            const SizedBox(height: 10),

            // 2️⃣ Absences par module
            const Text('Absences par module',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: absencesByModule.length,
                itemBuilder: (context, index) {
                  String module = absencesByModule.keys.elementAt(index);
                  int count = absencesByModule[module]!;
                  Color color = count <= 2
                      ? Colors.green
                      : (count <= 4 ? Colors.orange : Colors.red);
                  return Card(
                    child: ListTile(
                      title: Text(module),
                      trailing: CircleAvatar(
                        backgroundColor: color,
                        child: Text('$count',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 3️⃣ Dates des séances manquées
            const Text('Séances manquées',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: sessionDates.length,
                itemBuilder: (context, index) {
                  final s = sessionDates[index];
                  return Card(
                    child: ListTile(
                      title: Text('${s['module']} - ${s['date']}'),
                      trailing: CircleAvatar(
                        backgroundColor: getStatusColor(s['status']!),
                        child: Text(
                          s['status']![0], // P/J/A
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
