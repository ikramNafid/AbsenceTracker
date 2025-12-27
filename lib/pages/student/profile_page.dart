import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ProfilePage extends StatelessWidget {
  final int studentId;

  const ProfilePage({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon profil"),
        centerTitle: true,
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: DatabaseHelper.instance.getStudentProfile(studentId),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Profil introuvable"));
          }

          final student = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // Avatar
                const CircleAvatar(
                  radius: 45,
                  child: Icon(Icons.person, size: 45),
                ),

                const SizedBox(height: 20),

                Text(
                  "${student['firstName']} ${student['lastName']}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(student['email']),
                Text("Massar : ${student['massar']}"),
                Text("Groupe : ${student['groupName']}"),
                Text("Filière : ${student['filiere']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
