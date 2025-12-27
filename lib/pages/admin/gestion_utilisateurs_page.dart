import 'package:flutter/material.dart';
import 'gestion_etudiants_page.dart';
import 'gestion_professeurs_page.dart';
import 'gestion_coordinateurs_page.dart';

class GestionUtilisateursPage extends StatelessWidget {
  const GestionUtilisateursPage({super.key});

  static const Color lightBlue = Color(0xFF3B82F6); // bleu principal
  static const Color backgroundGray = Color(0xFFF3F6FB); // fond gris clair

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: lightBlue,
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Gestion des utilisateurs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 100), // espace pour le bouton flottant
          ],
        ),
      ),

      // 🔽 Bouton retour professionnel
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.white,
        foregroundColor: lightBlue,
        elevation: 6,
        icon: const Icon(Icons.arrow_back),
        label: const Text(
          'Retour',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBlue, width: 1.5),
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
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: Container(
            decoration: BoxDecoration(
              color: lightBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 32, color: lightBlue),
          ),
          title: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87),
          ),
          trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
        ),
      ),
    );
  }
}
