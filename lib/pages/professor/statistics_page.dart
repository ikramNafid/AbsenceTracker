import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/database_helper.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, int> _stats = {'present': 0, 'absent': 0, 'justified': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;

    // Nous récupérons toutes les absences pour calculer les ratios
    final allAbsences = await db.getAllAbsences();

    int p = 0;
    int a = 0;
    int j = 0;

    for (var row in allAbsences) {
      if (row['status'] == 'present')
        p++;
      else if (row['status'] == 'absent')
        a++;
      else if (row['status'] == 'justified') j++;
    }

    setState(() {
      _stats = {'present': p, 'absent': a, 'justified': j};
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analyses & Stats")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text("Taux de présence global",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  // --- GRAPHIQUE ---
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: _buildChartSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),

                  // --- LÉGENDE ---
                  _buildLegend(),

                  const Divider(height: 40),

                  // --- RÉSUMÉ CHIFFRÉ ---
                  _buildStatTile(
                      "Total Présences", _stats['present']!, Colors.green),
                  _buildStatTile(
                      "Total Absences", _stats['absent']!, Colors.red),
                  _buildStatTile(
                      "Cas Justifiés", _stats['justified']!, Colors.orange),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    int total = _stats.values.reduce((a, b) => a + b);
    if (total == 0)
      return [PieChartSectionData(color: Colors.grey, value: 1, title: "N/A")];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: _stats['present']!.toDouble(),
        title: '${((_stats['present']! / total) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: _stats['absent']!.toDouble(),
        title: '${((_stats['absent']! / total) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: _stats['justified']!.toDouble(),
        title: '${((_stats['justified']! / total) * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Présent", Colors.green),
        const SizedBox(width: 15),
        _legendItem("Absent", Colors.red),
        const SizedBox(width: 15),
        _legendItem("Justifié", Colors.orange),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildStatTile(String label, int count, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 10),
        title: Text(label),
        trailing: Text(count.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
