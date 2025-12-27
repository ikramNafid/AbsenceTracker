import 'package:flutter/material.dart';
import "../../../database/database_helper.dart";

class FilierePage extends StatefulWidget {
  const FilierePage({super.key});

  @override
  State<FilierePage> createState() => _FilierePageState();
}

class _FilierePageState extends State<FilierePage> {
  List<Map<String, dynamic>> filieres = [];
  List<Map<String, dynamic>> filteredFilieres = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFilieres();
  }

  Future<void> _loadFilieres() async {
    filieres = await DatabaseHelper.instance.getFilieres();
    setState(() {
      filteredFilieres = filieres;
    });
  }

  void _filterFilieres(String query) {
    final filtered = filieres
        .where((f) =>
            f['nom'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredFilieres = filtered;
    });
  }

  Future<void> _showFiliereForm({Map<String, dynamic>? filiere}) async {
    final nomController = TextEditingController(text: filiere?['nom'] ?? '');
    final descController =
        TextEditingController(text: filiere?['description'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            filiere == null ? 'Ajouter une filière' : 'Modifier la filière'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            onPressed: () async {
              final data = {
                'nom': nomController.text,
                'description': descController.text,
              };
              if (filiere == null) {
                await DatabaseHelper.instance.insertFiliere(data);
              } else {
                await DatabaseHelper.instance
                    .updateFiliere(filiere['id'], data);
              }
              Navigator.pop(context);
              _loadFilieres();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFiliere(int id) async {
    await DatabaseHelper.instance.deleteFiliere(id);
    _loadFilieres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        title: const Text('Gestion des filières'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher une filière...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterFilieres,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: filteredFilieres.length,
                  itemBuilder: (context, index) {
                    final f = filteredFilieres[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(f['nom']),
                        subtitle: Text(f['description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showFiliereForm(filiere: f),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFiliere(f['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showFiliereForm(),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une filière'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
