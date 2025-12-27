import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../attendance/read_only_attendance_page.dart';

class PastSessionsPage extends StatefulWidget {
  final DateTime selectedDate;
  const PastSessionsPage({super.key, required this.selectedDate});

  @override
  State<PastSessionsPage> createState() => _PastSessionsPageState();
}

class _PastSessionsPageState extends State<PastSessionsPage> {
  late Future<List<Map<String, dynamic>>> sessionsFuture;

  @override
  void initState() {
    super.initState();
    final date =
        "${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}";
    sessionsFuture = DatabaseHelper.instance.getSessionsByDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Séances passées")),
      body: FutureBuilder(
        future: sessionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data as List<Map<String, dynamic>>;

          if (sessions.isEmpty) {
            return const Center(child: Text("Aucune séance"));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              return Card(
                child: ListTile(
                  title: Text("${s['moduleName']} (${s['type']})"),
                  subtitle: Text("Groupe: ${s['groupName']} | ${s['time']}"),
                  trailing: const Icon(Icons.lock),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReadOnlyAttendancePage(
                          sessionId: s['id'],
                          groupId: s['groupId'],
                        ),
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
