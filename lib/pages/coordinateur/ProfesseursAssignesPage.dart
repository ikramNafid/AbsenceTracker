import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ProfesseursAssignesPage extends StatefulWidget {
  const ProfesseursAssignesPage({super.key});

  @override
  State<ProfesseursAssignesPage> createState() =>
      _ProfesseursAssignesPageState();
}

class _ProfesseursAssignesPageState extends State<ProfesseursAssignesPage> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final res = await DatabaseHelper.instance.getProfesseursWithModules();
    setState(() {
      data = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Grouper par professeur
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var row in data) {
      final prof = row['professeur'];
      grouped.putIfAbsent(prof, () => []);
      grouped[prof]!.add(row);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Professeurs & Modules assignés"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : grouped.isEmpty
              ? const Center(
                  child: Text("Aucune affectation trouvée"),
                )
              : ListView(
                  children: grouped.entries.map((entry) {
                    final prof = entry.key;
                    final modules = entry.value;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prof,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            ...modules.map((m) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    "• ${m['module']} "
                                    "${m['groupe'] != null ? '(Groupe : ${m['groupe']})' : ''}",
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
