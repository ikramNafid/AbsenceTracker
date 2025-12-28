import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../groups_page.dart'; // Page qui affiche les groupes d’un module

class ModulesPage extends StatefulWidget {
  final int profId;

  const ModulesPage({super.key, required this.profId});

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  List<Map<String, dynamic>> modules = [];
  List<Map<String, dynamic>> filteredModules = [];
  final TextEditingController searchController = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final data =
          await DatabaseHelper.instance.getModulesByProfesseur(widget.profId);
      setState(() {
        modules = data;
        filteredModules = data;
        loading = false;
      });
    } catch (e) {
      print('Erreur chargement modules: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void _filterModules(String query) {
    setState(() {
      filteredModules = modules
          .where((m) =>
              m['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Nouvelle méthode pour naviguer vers la page des groupes
  void _goToGroupsPage(int moduleId, String moduleName) async {
    final groups = await DatabaseHelper.instance.getGroupsByModule(moduleId);
    if (groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun groupe trouvé pour ce module"),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupsPage(moduleName: moduleName, groups: groups),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modules assignés au professeur'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterModules,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un module',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredModules.isEmpty
                      ? const Center(child: Text('Aucun module affecté'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredModules.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemBuilder: (context, index) {
                            final module = filteredModules[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                _goToGroupsPage(module['id'], module['name']);
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.book,
                                        size: 50, color: Colors.blue),
                                    const SizedBox(height: 12),
                                    Text(
                                      module['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (module['semester'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          'Semestre ${module['semester']}',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
