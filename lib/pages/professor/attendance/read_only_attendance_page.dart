import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class ReadOnlyAttendancePage extends StatelessWidget {
  final int sessionId;
  final int groupId;

  const ReadOnlyAttendancePage({
    super.key,
    required this.sessionId,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Absences (lecture seule)")),
      body: FutureBuilder(
        future: DatabaseHelper.instance.getStudentsByGroup(groupId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text("${student['firstName']} ${student['lastName']}"),
                trailing: FutureBuilder(
                  future:
                      DatabaseHelper.instance.getAbsencesBySession(sessionId),
                  builder: (context, absSnapshot) {
                    if (!absSnapshot.hasData) {
                      return const SizedBox();
                    }

                    final absences =
                        absSnapshot.data as List<Map<String, dynamic>>;

                    final absence = absences.firstWhere(
                      (a) => a['studentId'] == student['id'],
                      orElse: () => {},
                    );

                    final status = absence['status'] ?? 'Présent';

                    IconData icon;
                    if (status == 'Absent') {
                      icon = Icons.close;
                    } else if (status == 'Justifié') {
                      icon = Icons.info;
                    } else {
                      icon = Icons.check;
                    }

                    return Icon(icon);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
