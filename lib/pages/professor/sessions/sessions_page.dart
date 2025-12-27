import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import 'absence_page.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() async {
    final data = await DatabaseHelper.instance.getSessionsToday();
    setState(() => sessions = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Séances du jour")),
      body: sessions.isEmpty
          ? const Center(child: Text("Aucune séance prévue aujourd'hui"))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final s = sessions[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.event_note, color: Colors.indigo),
                    title: Text(s['moduleName']),
                    subtitle: Text("${s['groupName']} • ${s['time']}"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AbsencePage(
                            sessionId: s['id'],
                            moduleName: s['moduleName'],
                            groupName: s['groupName'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
