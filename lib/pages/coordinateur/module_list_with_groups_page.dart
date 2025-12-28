import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'module_management_page.dart';

class ModuleListWithGroupsPage extends StatefulWidget {
  final int filiereId;
  const ModuleListWithGroupsPage({super.key, required this.filiereId});

  @override
  State<ModuleListWithGroupsPage> createState() =>
      _ModuleListWithGroupsPageState();
}

class _ModuleListWithGroupsPageState extends State<ModuleListWithGroupsPage> {
  late Future<List<Map<String, dynamic>>> _modulesFuture;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  void _loadModules() {
    _modulesFuture = DatabaseHelper.instance.getAllModules();
  }

  Future<void> _deleteModule(int moduleId) async {
    await DatabaseHelper.instance.deleteModule(moduleId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Module supprimé avec succès"),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _loadModules());
  }

  void _editModule(Map<String, dynamic> module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModuleManagementPage(
          filiereId: widget.filiereId,
        ),
      ),
    ).then((_) => setState(() => _loadModules()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // 🔹 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              "Gestion des modules",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Liste des modules",
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),

      // 🔹 BODY
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _modulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Aucun module trouvé",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ajoutez un module pour commencer",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final modules = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (_, index) {
              final m = modules[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

                  // 🔹 ICON
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.blue,
                    ),
                  ),

                  // 🔹 TITLE
                  title: Text(
                    m['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  // 🔹 SUBTITLE
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.school, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Semestre ${m['semester']}",
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 ACTIONS
                  trailing: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _editModule(m);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Confirmation"),
                            content: const Text(
                                "Voulez-vous vraiment supprimer ce module ?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Annuler"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Supprimer"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _deleteModule(m['id']);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Modifier"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Supprimer"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // 🔹 FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text("Ajouter un module"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModuleManagementPage(filiereId: widget.filiereId),
            ),
          ).then((_) => setState(() => _loadModules()));
        },
      ),
    );
  }
}
