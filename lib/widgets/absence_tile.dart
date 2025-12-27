import 'package:absence_tracker/models/absence_model.dart';
import 'package:flutter/material.dart';

class AbsenceTile extends StatelessWidget {
  final Absence absence;

  const AbsenceTile({super.key, required this.absence});

  @override
  Widget build(BuildContext context) {
    Color color;

    // Utilisation de .toLowerCase() pour être sûr que le switch fonctionne
    switch (absence.status.toLowerCase()) {
      case "absent":
        color = Colors.red;
        break;
      case "justified":
      case "justifié":
        color = Colors.orange;
        break;
      case "présent":
      case "present":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.event, color: color),
        title: Text(absence.moduleName),
        // Correction ici : ajout des accolades ${ }
        subtitle: Text("Date : ${absence.date}"),
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
