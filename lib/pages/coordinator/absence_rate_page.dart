import 'package:flutter/material.dart';

class AbsenceRatePage extends StatelessWidget {
  const AbsenceRatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taux d'absences"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
              title: Text("Ahmed Ali"), subtitle: Text("Java - 2 absences")),
          ListTile(
              title: Text("Sara Benali"), subtitle: Text("Maths - 4 absences")),
        ],
      ),
    );
  }
}
