import 'package:flutter/material.dart';

class GestionProfesseursPage extends StatelessWidget {
  const GestionProfesseursPage({super.key});

  static const Color lightBlue = Color(0xFF4A90E2); // 🔵 Bleu clair

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ✅ AppBar unique en bleu clair avec titre blanc
      appBar: AppBar(
        backgroundColor: lightBlue,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Gestion des professeurs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ✅ Body sans espace inutile sous l'AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gérer vos professeurs : liste, importation et édition',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Actions comme boutons
            _buildActionButton(
              context,
              icon: Icons.list,
              title: 'Liste des professeurs',
              color: Colors.blue,
              onTap: () {
                // action liste
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.upload_file,
              title: 'Importer CSV',
              color: Colors.green,
              onTap: () {
                // action import
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.edit,
              title: 'Gérer professeurs',
              color: Colors.orange,
              onTap: () {
                // action gestion
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.search,
              title: 'Rechercher',
              color: Colors.purple,
              onTap: () {
                // action recherche
              },
            ),
          ],
        ),
      ),

      // ✅ Bouton retour en bas centré
      floatingActionButton: SizedBox(
        width: 150,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: lightBlue,
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        leading: Icon(icon, size: 32, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
