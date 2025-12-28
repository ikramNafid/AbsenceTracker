import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class DistributeModulesByGroupPage extends StatefulWidget {
  final int filiereId;

  const DistributeModulesByGroupPage({Key? key, required this.filiereId})
      : super(key: key);

  @override
  State<DistributeModulesByGroupPage> createState() =>
      _DistributeModulesByGroupPageState();
}

class _DistributeModulesByGroupPageState
    extends State<DistributeModulesByGroupPage> {
  List<Map<String, dynamic>> modules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() => isLoading = true);

    final data = await DatabaseHelper.instance
        .getModulesWithGroupsByFiliere(widget.filiereId);

    setState(() {
      modules = data;
      isLoading = false;
    });
  }

  // 🔹 AFFECTATION MODULE → GROUPES
  void _assignGroups(Map<String, dynamic> module) async {
    final groups =
        await DatabaseHelper.instance.getGroupsByFiliere(widget.filiereId);

    List<int> selectedGroupIds = [];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Affecter ${module['moduleName']}"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: groups.map((g) {
                    return CheckboxListTile(
                      title: Text(g['name']),
                      value: selectedGroupIds.contains(g['id']),
                      onChanged: (value) {
                        setStateDialog(() {
                          if (value == true) {
                            selectedGroupIds.add(g['id']);
                          } else {
                            selectedGroupIds.remove(g['id']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Annuler"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Valider"),
                  onPressed: () async {
                    await DatabaseHelper.instance.assignModuleToGroups(
                      module['id'],
                      selectedGroupIds,
                    );
                    Navigator.pop(context);
                    _loadModules();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Module affecté avec succès"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Répartition des modules par groupe"),
        backgroundColor: Colors.lightBlue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : modules.isEmpty
              ? const Center(child: Text("Aucun module trouvé"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: modules.length,
                  itemBuilder: (_, index) {
                    final m = modules[index];
                    final groupsText = (m['groups'] as List).isEmpty
                        ? "Aucun groupe"
                        : (m['groups'] as List).join(', ');

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          m['moduleName'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Groupes : $groupsText"),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _assignGroups(m),
                          icon: const Icon(Icons.group_add),
                          label: const Text("Affecter"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
