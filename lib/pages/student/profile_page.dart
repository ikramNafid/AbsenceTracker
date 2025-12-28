import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ProfilePage extends StatefulWidget {
  final int studentId;

  const ProfilePage({super.key, required this.studentId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>?>? _studentFuture;

  @override
  void initState() {
    super.initState();
    _studentFuture =
        DatabaseHelper.instance.getStudentProfile(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Profil introuvable"));
          }

          final userData = snapshot.data!;

          return Column(
            children: [
              // Header Profil
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.indigo),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "${userData['firstName']} ${userData['lastName']}",
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userData['email'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Détails
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildProfileItem(Icons.badge, "Rôle", "Etudiant"),
                    _buildProfileItem(
                        Icons.email, "Email Institutionnel", userData['email']),
                    const Divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.help_outline, color: Colors.blue),
                      title: const Text("Support"),
                      subtitle: const Text("Contacter l'administration"),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title:
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}
