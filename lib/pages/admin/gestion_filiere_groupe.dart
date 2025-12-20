import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class GestionFiliereGroupe extends StatefulWidget {
  const GestionFiliereGroupe({super.key});

  @override
  State<GestionFiliereGroupe> createState() => _GestionFiliereGroupeState();
}

class _GestionFiliereGroupeState extends State<GestionFiliereGroupe> {
  int _selectedIndex = 0; // 0 = Filières, 1 = Groupes
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const FilierePage(),
      const GroupePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 2,
        title: Text(
          _selectedIndex == 0 ? 'Gestion des filières' : 'Gestion des groupes',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4A90E2)),
              child: Text(
                'Gestion Académique',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Filières'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Groupes'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Retour'),
              onTap: () {
                Navigator.pop(context);
                Navigator.maybePop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

// ================== Page Filières ==================
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
    return Padding(
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
                            icon: const Icon(Icons.edit, color: Colors.orange),
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
    );
  }
}

// ================== Page Groupes ==================
class GroupePage extends StatefulWidget {
  const GroupePage({super.key});

  @override
  State<GroupePage> createState() => _GroupePageState();
}

class _GroupePageState extends State<GroupePage> {
  List<Map<String, dynamic>> filieres = [];
  List<Map<String, dynamic>> groupes = [];
  String? selectedFiliereId;
  TextEditingController nomGroupeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFilieres();
    _loadGroupes();
  }

  Future<void> _loadFilieres() async {
    filieres = await DatabaseHelper.instance.getFilieres();
    if (filieres.isNotEmpty) selectedFiliereId = filieres[0]['id'].toString();
    setState(() {});
  }

  Future<void> _loadGroupes() async {
    groupes = await DatabaseHelper.instance.getGroups();
    setState(() {});
  }

  Future<void> _showGroupeForm({Map<String, dynamic>? groupe}) async {
    final nomController = TextEditingController(text: groupe?['name'] ?? '');
    String? filiereId =
        groupe != null ? groupe['idFiliere'].toString() : selectedFiliereId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(groupe == null ? 'Ajouter un groupe' : 'Modifier le groupe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom du groupe'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: filiereId,
              items: filieres
                  .map((f) => DropdownMenuItem(
                        value: f['id'].toString(),
                        child: Text(f['nom']),
                      ))
                  .toList(),
              onChanged: (val) => filiereId = val,
              decoration: const InputDecoration(
                labelText: 'Sélectionner une filière',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            onPressed: () async {
              if (nomController.text.isEmpty || filiereId == null) return;
              final data = {
                'name': nomController.text,
                'idFiliere': int.parse(filiereId!),
              };
              if (groupe == null) {
                await DatabaseHelper.instance.insertGroup(data);
              } else {
                await DatabaseHelper.instance.updateGroup(groupe['id'], data);
              }
              Navigator.pop(context);
              _loadGroupes();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroupe(int id) async {
    await DatabaseHelper.instance.deleteGroup(id);
    _loadGroupes();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Groupe supprimé')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(height: 30, thickness: 2),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(8),
              child: ListView(
                children: groupes.map((g) {
                  final filiereNom = filieres
                      .firstWhere((f) => f['id'] == g['idFiliere'],
                          orElse: () => {'nom': 'Non défini'})['nom']
                      .toString();
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(g['name']),
                      subtitle: Text('Filière: $filiereNom'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showGroupeForm(groupe: g),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteGroupe(g['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showGroupeForm(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un groupe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
