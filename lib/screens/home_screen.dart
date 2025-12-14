import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../providers/session_provider.dart';
import '../models/session_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final sessions = context.watch<SessionProvider>().getUpcomingSessions();

    return Scaffold(
      appBar: AppBar(title: const Text('Absence Tracker'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: Colors.red[50],
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.red),
                title: const Text('Taux d\'absences'),
                subtitle: Text('${stats.absenceRate}%'),
              ),
            ),
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Module le plus manqué'),
                subtitle: Text(stats.mostMissedModule ?? 'Aucun'),
              ),
            ),
            Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: const Icon(Icons.group, color: Colors.blue),
                title: const Text('Groupes actifs aujourd\'hui'),
                subtitle: Text(stats.activeGroupsToday.join(', ')),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Séances à venir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...sessions.map((SessionModel session) {
              return Card(
                child: ListTile(
                  title: Text('Séance ${session.id}'),
                  subtitle: Text(
                    '${session.moduleName} - ${session.date} à ${session.time}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/markAbsence',
                      arguments: session,
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/groups');
              break;
            case 2:
              Navigator.pushNamed(context, '/sessions');
              break;
            case 3:
              Navigator.pushNamed(context, '/statistics');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groupes'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Séances'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}
