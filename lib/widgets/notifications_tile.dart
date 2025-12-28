import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String date;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isRead ? Colors.grey[200] : Colors.blue[50],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: isRead ? Colors.grey : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(message),
        trailing: Text(
          date,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
