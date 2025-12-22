import 'package:flutter/material.dart';
import 'package:absence_tracker/database/database_helper.dart';
import 'package:absence_tracker/models/session_model.dart';
import 'add_session_page.dart';

class SessionsListPage extends StatefulWidget {
  const SessionsListPage({Key? key}) : super(key: key);

  @override
  State<SessionsListPage> createState() => _SessionsListPageState();
}

class _SessionsListPageState extends State<SessionsListPage> {
  late Future<List<SessionModel>> _sessions;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessions = DatabaseHelper.instance.getSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Sessions')),
      body: FutureBuilder<List<SessionModel>>(
        future: _sessions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune session trouvée'));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                title: Text(session.name),
                subtitle: Text('Groupe: ${session.groupName}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await DatabaseHelper.instance.deleteSession(session.id!);
                    setState(() {
                      _loadSessions();
                    });
                  },
                ),
                onTap: () {
                  // Page détails session à ajouter plus tard
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSessionPage()),
          ).then((_) => _loadSessions());
        },
      ),
    );
  }
}
