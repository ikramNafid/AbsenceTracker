import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../take_attendance_page.dart';

class SessionsTodayPage extends StatelessWidget {
  final int profId;
  const SessionsTodayPage({super.key, required this.profId});

  Future<List<Map<String, dynamic>>> _loadTodaySessions() async {
    return await DatabaseHelper.instance.getTodaySessionsByProf(profId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Séances du jour")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadTodaySessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune séance aujourd’hui'));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(session['moduleName'] ?? 'Module inconnu'),
                  subtitle: Text(
                      '${session['groupName'] ?? ''} - ${session['time']}'),
                  trailing: Text(session['type'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TakeAttendancePage(sessionId: session['id']),
                      ),
                    );
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
