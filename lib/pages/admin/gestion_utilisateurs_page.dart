import 'package:flutter/material.dart';
import 'gestion_etudiants_page.dart';
import 'gestion_professeurs_page.dart';
import 'gestion_coordinateurs_page.dart';

class GestionUtilisateursPage extends StatelessWidget {
  const GestionUtilisateursPage({super.key});

  static const Color lightBlue = Color(0xFF4A90E2); // 🔵 Bleu clair

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: lightBlue,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Gestion des utilisateurs',
          style: TextStyle(
            color: Colors.white, // ⚪ titre blanc
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // ⚪ icônes blanches
        ),
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

            const SizedBox(height: 80), // espace pour le bouton flottant
          ],
        ),
      ),

      /// 🔽 Bouton flèche retour
      floatingActionButton: SizedBox(
        width: 150,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: lightBlue, // même bleu clair
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        leading: Icon(icon, size: 32, color: lightBlue),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}
