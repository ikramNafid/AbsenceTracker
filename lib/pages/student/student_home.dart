import 'package:absence_tracker/widgets/homeButton.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  final String studentName;
  final String groupName;

  const StudentHomePage({
    super.key,
    required this.studentName,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Espace Étudiant"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Message de bienvenue
            Text(
              "Bonjour, $studentName ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            //  Groupe
            Text(
              "Groupe : $groupName",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            SizedBox(height: 30),

            // Historique
            HomeButton(
              icon: Icons.history,
              title: "Mes absences",
              onTap: () {
                // Navigator.push(...)
              },
            ),

            // Notifications
            HomeButton(
              icon: Icons.notifications,
              title: "Notifications",
              onTap: () {
                // Navigator.push(...)
              },
            ),

            // 📷 QR Code
            HomeButton(
              icon: Icons.qr_code_scanner,
              title: "Valider ma présence",
              onTap: () {
                // Navigator.push(...)
              },
            ),
          ],
        ),
      ),
    );
  }
}
