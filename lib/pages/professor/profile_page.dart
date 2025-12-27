import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _passwordController = TextEditingController();

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Changer le mot de passe"),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Nouveau mot de passe",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_passwordController.text.isNotEmpty) {
                await DatabaseHelper.instance.updateProfessorPassword(
                    widget.userData['id'], _passwordController.text);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mot de passe mis à jour !")),
                );
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
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
                  "${widget.userData['firstName']} ${widget.userData['lastName']}",
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.userData['email'],
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
                _buildProfileItem(Icons.badge, "Rôle",
                    "Professeur (Niveau ${widget.userData['role']})"),
                _buildProfileItem(Icons.email, "Email Institutionnel",
                    widget.userData['email']),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Colors.orange),
                  title: const Text("Sécurité"),
                  subtitle: const Text("Modifier mon mot de passe"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showChangePasswordDialog,
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: const Text("Support"),
                  subtitle: const Text("Contacter l'administration"),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
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
