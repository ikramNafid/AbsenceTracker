import 'package:absence_tracker/widgets/notificationTile.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: const [
          NotificationTile(
            title: "Absence enregistrée",
            message: "Vous étiez absent au module Mobile.",
            date: "24/02/2025",
            isRead: false,
          ),
          NotificationTile(
            title: "Absence justifiée",
            message: "Votre absence a été justifiée.",
            date: "20/02/2025",
            isRead: true,
          ),
        ],
      ),
    );
  }
}

