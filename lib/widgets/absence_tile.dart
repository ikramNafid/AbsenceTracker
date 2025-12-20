import 'package:absence_tracker/models/absence_model.dart';
import 'package:flutter/material.dart';

class AbsenceTile extends StatelessWidget {
  final Absence absence;
  

  const AbsenceTile({
    super.key,
    required this.absence});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (absence.status) {
      case "absent":
        color = Colors.red;
        break;
      case "justified":
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.event, color: color),
        title: Text(absence.moduleName),
        subtitle: Text("Date : $absence.date"),
        trailing: Text(
          absence.status.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
