import 'package:flutter/material.dart';
import "../../../database/database_helper.dart";

class AffectationPage extends StatefulWidget {
  const AffectationPage({super.key});

  @override
  State<AffectationPage> createState() => _AffectationPageState();
}

class _AffectationPageState extends State<AffectationPage> {
  List<Map<String, dynamic>> filieres = [];
  List<Map<String, dynamic>> coordinateurs = [];
  String? selectedFiliereId;
  String? selectedCoordinateurId;

  @override
  void initState() {
    super.initState();
    _loadFilieres();
    _loadCoordinateurs();
  }

  // Charger les filières depuis la base de données
  Future<void> _loadFilieres() async {
    filieres = await DatabaseHelper.instance.getFilieres();
    if (filieres.isNotEmpty) selectedFiliereId = filieres[0]['id'].toString();
    setState(() {});
  }

  // Charger les coordinateurs depuis la base de données
  Future<void> _loadCoordinateurs() async {
    coordinateurs = await DatabaseHelper.instance.getCoordinateurs();
    if (coordinateurs.isNotEmpty)
      selectedCoordinateurId = coordinateurs[0]['id'].toString();
    setState(() {});
  }

  // Affecter une filière à un coordinateur
  Future<void> _assignFiliere() async {
    if (selectedFiliereId == null || selectedCoordinateurId == null) return;

    // Vérifier que la méthode existe dans DatabaseHelper
    await DatabaseHelper.instance.assignFiliereToCoordinateur(
      int.parse(selectedFiliereId!),
      int.parse(selectedCoordinateurId!),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filière affectée avec succès !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        title: const Text('Affectation des filières'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown Filières
            DropdownButtonFormField<String>(
              value: selectedFiliereId,
              decoration:
                  const InputDecoration(labelText: 'Sélectionner une filière'),
              items: filieres
                  .map((f) => DropdownMenuItem(
                        value: f['id'].toString(),
                        child: Text(f['nom']),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedFiliereId = val),
            ),
            const SizedBox(height: 16),
            // Dropdown Coordinateurs
            DropdownButtonFormField<String>(
              value: selectedCoordinateurId,
              decoration: const InputDecoration(
                  labelText: 'Sélectionner un coordinateur'),
              items: coordinateurs
                  .map((c) => DropdownMenuItem(
                        value: c['id'].toString(),
                        child: Text('${c['firstName']} ${c['lastName']}'),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedCoordinateurId = val),
            ),
            const SizedBox(height: 20),
            // Bouton Affecter
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _assignFiliere,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Affecter la filière'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
