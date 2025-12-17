import 'package:flutter/material.dart';
import 'gestion_etudiants_page.dart';
import 'gestion_professeurs_page.dart';
import 'gestion_coordinateurs_page.dart';

class GestionUtilisateursPage extends StatelessWidget {
  const GestionUtilisateursPage({super.key});

  static const Color primaryBlue = Color(0xFF0A2E5C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Gestion des utilisateurs'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCard(
              context,
              icon: Icons.school,
              title: 'Gestion des étudiants',
              page: const GestionEtudiantsPage(),
            ),
            _buildCard(
              context,
              icon: Icons.person,
              title: 'Gestion des professeurs',
              page: const GestionProfesseursPage(),
            ),
            _buildCard(
              context,
              icon: Icons.manage_accounts,
              title: 'Gestion des coordinateurs',
              page: const GestionCoordinateursPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        leading: Icon(icon, size: 32, color: primaryBlue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
