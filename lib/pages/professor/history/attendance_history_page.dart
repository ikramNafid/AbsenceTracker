import 'package:flutter/material.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {"student": "Ali Ahmed", "date": "2025-12-20", "status": "✓ Présent"},
      {"student": "Sara Noor", "date": "2025-12-20", "status": "✗ Absent"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Historique des absences")),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final h = history[index];
          return Card(
            child: ListTile(
              title: Text(h["student"]!),
              subtitle: Text("Date : ${h["date"]}"),
              trailing: Text(h["status"]!),
            ),
          );
        },
      ),
    );
  }
}
