import 'package:flutter/material.dart';
import '../../widgets/prof_drawer.dart';

class ProfHome extends StatelessWidget {
  const ProfHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil Professeur')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            const Text('Mes groupes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(child: _groupsSection(context)),
            const SizedBox(height: 20),
            const Text('Séances du jour',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(child: _sessionsSection()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prof. Ahmed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                'Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
            const SizedBox(height: 6),
            const Text('Vous avez 2 séances aujourd’hui',
                style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _groupsSection(BuildContext context) {
    final List<Map<String, dynamic>> groups = [
      {'name': 'Groupe A', 'module': 'Mathématiques', 'students': 28},
      {'name': 'Groupe B', 'module': 'Informatique', 'students': 32},
    ];

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final g = groups[index];
        return Card(
          child: ListTile(
            title: Text(g['name'] as String),
            subtitle:
                Text('${g['module'] as String} • ${g['students']} étudiants'),
            trailing: ElevatedButton(
              onPressed: () {
                // Naviguer vers MarkAbsencePage avec le groupe sélectionné
              },
              child: const Text('Absences'),
            ),
          ),
        );
      },
    );
  }

  Widget _sessionsSection() {
    final List<Map<String, String>> sessions = [
      {
        'group': 'Groupe A',
        'time': '08:30',
        'room': 'Salle 101',
        'status': 'À faire'
      },
      {
        'group': 'Groupe B',
        'time': '10:30',
        'room': 'Salle 202',
        'status': 'Fait'
      },
    ];

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final s = sessions[index];
        return ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(s['group'] as String),
          subtitle: Text('${s['time']} - ${s['room']}'),
          trailing: Chip(
            label: Text(s['status'] as String),
            backgroundColor:
                s['status'] == 'Fait' ? Colors.green[200] : Colors.orange[200],
          ),
        );
      },
    );
  }
}
