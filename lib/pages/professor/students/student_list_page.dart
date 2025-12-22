import 'package:flutter/material.dart';
import 'package:absence_tracker/database/database_helper.dart';

class StudentsListPage extends StatelessWidget {
  final int groupId; // <-- déclaration ici

  const StudentsListPage({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Étudiants')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getStudentsByGroup(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun étudiant trouvé'));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text('${student['firstName']} ${student['lastName']}'),
                subtitle: Text('Email: ${student['email']}'),
              );
            },
          );
        },
      ),
    );
  }
}
