import 'package:flutter/material.dart';

class AlertAbsencePage extends StatelessWidget {
  const AlertAbsencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alertes d'absence"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _alert("Sara Benali", 4),
          _alert("Youssef Amrani", 5),
        ],
      ),
    );
  }

  Widget _alert(String name, int absences) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text(name),
        subtitle: Text("Absences : $absences"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {},
          child: const Text("Alerter"),
        ),
      ),
    );
  }
}
