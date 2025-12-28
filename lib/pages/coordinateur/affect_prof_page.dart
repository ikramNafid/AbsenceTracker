import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AffectProfPage extends StatefulWidget {
  const AffectProfPage({super.key});

  @override
  State<AffectProfPage> createState() => _AffectProfPageState();
}

class _AffectProfPageState extends State<AffectProfPage> {
  List<Map<String, dynamic>> modules = [];
  List<Map<String, dynamic>> profs = [];

  int? selectedProfId;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;

    final modulesData = await db.getModulesWithGroups();
    final profsData = await db.getProfesseurs();

    setState(() {
      modules = modulesData;
      profs = profsData;
      isLoading = false;
    });
  }

  void _affecterProf(int moduleId) async {
    if (selectedProfId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir un professeur")),
      );
      return;
    }

    try {
      final db = DatabaseHelper.instance;

      // 🔹 Affecter le module au professeur
      await db.affecterModuleAProf(moduleId, selectedProfId!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Professeur affecté avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'affectation: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Affectation modules → professeurs"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ================== DROPDOWN PROF ==================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                        labelText: "Choisir un professeur"),
                    items: profs.map((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'],
                        child: Text("${p['firstName']} ${p['lastName']}"),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() => selectedProfId = v);
                    },
                  ),
                ),

                const Divider(),

                // ================== LISTE MODULES ==================
                Expanded(
                  child: ListView.builder(
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      final m = modules[index];
                      final List groups = m['groups'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            m['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            groups.isEmpty
                                ? "Aucun groupe affecté"
                                : "Groupes : ${groups.join(', ')}",
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _affecterProf(m['id']),
                            child: const Text("Affecter"),
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
