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

    // Grouper par professeur
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var row in res) {
      final prof = row['professeur'] ?? '';
      grouped.putIfAbsent(prof, () => []);
      grouped[prof]!.add(row);
    }

    // Convertir en liste pour DataTable
    List<Map<String, dynamic>> groupedList = [];
    grouped.forEach((prof, modules) {
      groupedList.add({
        'professeur': prof,
        'modules': modules
            .map((m) =>
                m['module']! +
                (m['groupe'] != null ? ' (Groupe: ${m['groupe']})' : ''))
            .join('\n'),
      });
    });

    setState(() {
      data = groupedList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Professeurs & Modules assignés"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Aucune affectation trouvée"))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                        Colors.blueGrey.shade50), // fond header
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                    dataRowHeight: 70, // ↑ hauteur globale des lignes
                    columnSpacing: 40,
                    columns: const [
                      DataColumn(
                        label: Text('Professeur'),
                      ),
                      DataColumn(
                        label: Text('Modules Assignés'),
                      ),
                    ],
                    rows: List.generate(data.length, (index) {
                      final row = data[index];
                      final isEven = index % 2 == 0;
                      return DataRow(
                        color: MaterialStateProperty.all(
                            isEven ? Colors.grey.shade100 : Colors.white),
                        cells: [
                          DataCell(
                            Container(
                              height: 60, // ↑ hauteur cellule
                              alignment: Alignment.centerLeft,
                              child: Text(
                                row['professeur'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              height: 60, // ↑ hauteur cellule
                              alignment: Alignment.centerLeft,
                              child: Text(
                                row['modules'] ?? '',
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
    );
  }
}
