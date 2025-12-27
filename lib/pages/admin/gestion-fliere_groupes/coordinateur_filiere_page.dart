import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class CoordinateurFilierePage extends StatefulWidget {
  const CoordinateurFilierePage({super.key});

  @override
  State<CoordinateurFilierePage> createState() =>
      _CoordinateurFilierePageState();
}

class _CoordinateurFilierePageState extends State<CoordinateurFilierePage> {
  // Map pour regrouper les filières par coordinateur
  Map<String, List<String>> assignments = {};

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final data = await DatabaseHelper.instance.getFiliereCoordinateurs();

      // Regrouper les filières par coordinateur
      Map<String, List<String>> grouped = {};
      for (var item in data) {
        final coordinateur = item['coordinateur'] as String;
        final filiere = item['filiere'] as String;

        if (!grouped.containsKey(coordinateur)) {
          grouped[coordinateur] = [];
        }
        grouped[coordinateur]!.add(filiere);
      }

      setState(() {
        assignments = grouped;
      });
    } catch (e) {
      print("Erreur lors du chargement des affectations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinateurs et leurs filières'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: assignments.isEmpty
            ? const Center(child: Text('Aucune affectation trouvée'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(
                        label: Text('Coordinateur',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))),
                    DataColumn(
                        label: Text('Filières',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))),
                  ],
                  rows: assignments.entries.map((entry) {
                    return DataRow(
                      cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.join(', '))),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
