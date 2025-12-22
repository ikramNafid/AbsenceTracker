import 'package:flutter/material.dart';
import 'package:absence_tracker/database/database_helper.dart';
import '../modules/module_details_page.dart';

class ModulesListPage extends StatefulWidget {
  const ModulesListPage({Key? key}) : super(key: key);

  @override
  State<ModulesListPage> createState() => _ModulesListPageState();
}

class _ModulesListPageState extends State<ModulesListPage> {
  late Future<List<Map<String, dynamic>>> _modules;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  void _loadModules() {
    _modules =
        DatabaseHelper.instance.getModules(); // À créer dans DatabaseHelper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Modules')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _modules,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun module trouvé'));
          }

          final modules = snapshot.data!;
          return ListView.builder(
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(module['name']),
                  subtitle: Text('Semestre: ${module['semester']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModuleDetailPage(module: module),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
