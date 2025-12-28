import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class GestionSessionPage extends StatefulWidget {
  const GestionSessionPage({super.key});

  @override
  State<GestionSessionPage> createState() => _GestionSessionPageState();
}

class _GestionSessionPageState extends State<GestionSessionPage> {
  int? selectedProf;
  int? selectedModule;

  List<Map<String, dynamic>> profs = [];
  List<Map<String, dynamic>> modules = [];
  bool isLoading = true;
  bool modulesLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfesseurs();
  }

  // Charger les professeurs avec des modules
  Future<void> _loadProfesseurs() async {
    final res = await DatabaseHelper.instance.getProfesseursWithModules();
    final Map<int, String> profsMap = {};
    for (var row in res) {
      final profId = row['profId'] as int;
      final profName = row['professeur'] as String;
      profsMap[profId] = profName; // écrase les doublons
    }

    setState(() {
      profs =
          profsMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
      isLoading = false;
    });
  }

  // Charger les modules assignés à un professeur
  Future<void> _loadModulesByProf(int profId) async {
    setState(() {
      modulesLoading = true;
      selectedModule = null;
      modules = [];
    });

    final res = await DatabaseHelper.instance.getModulesByProfesseur(profId);

    setState(() {
      modules = res
          .map((m) => {'id': m['id'], 'name': m['name'].toString()})
          .toList();
      modulesLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Séances"),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Dropdown Professeur
                  DropdownButtonFormField<int>(
                    value: selectedProf,
                    items: profs
                        .map((p) => DropdownMenuItem<int>(
                              value: p['id'] as int,
                              child: Text(p['name'].toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedProf = value;
                        });
                        _loadModulesByProf(value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Sélectionner un professeur",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown Modules
                  modulesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                          value: selectedModule,
                          items: modules
                              .map((m) => DropdownMenuItem<int>(
                                    value: m['id'] as int,
                                    child: Text(m['name'].toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedModule = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Sélectionner un module",
                            border: OutlineInputBorder(),
                          ),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (selectedProf == null || selectedModule == null)
                        ? null
                        : () async {
                            final profName = profs
                                .firstWhere(
                                    (p) => p['id'] == selectedProf)['name']
                                .toString();
                            final moduleName = modules
                                .firstWhere(
                                    (m) => m['id'] == selectedModule)['name']
                                .toString();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Professeur : $profName\nModule : $moduleName")),
                            );
                          },
                    child: const Text("Valider"),
                  ),
                ],
              ),
      ),
    );
  }
}
