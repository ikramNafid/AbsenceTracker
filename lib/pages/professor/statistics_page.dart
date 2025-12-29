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
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper.instance;
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
      _total = p + a + j;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Analyses & Stats",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header avec total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Récapitulatif Global",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("Basé sur $_total enregistrements d'appel",
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Graphique PieChart dans une carte élégante
                  _buildChartCard(),

                  const SizedBox(height: 20),

                  // Liste des statistiques détaillées
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Détails par catégorie",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey)),
                        const SizedBox(height: 12),
                        _buildStatTile("Total Présences", _stats['present']!,
                            Colors.green, Icons.check_circle_rounded),
                        _buildStatTile("Total Absences", _stats['absent']!,
                            Colors.red, Icons.cancel_rounded),
                        _buildStatTile("Cas Justifiés", _stats['justified']!,
                            Colors.orange, Icons.info_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const Text("Répartition des Statuts",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildChartSections(),
                centerSpaceRadius: 50,
                sectionsSpace: 4,
                startDegreeOffset: 180,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    if (_total == 0) {
      return [
        PieChartSectionData(
            color: Colors.grey.shade300, value: 1, title: "N/A", radius: 50)
      ];
    }

    return [
      _sectionData(_stats['present']!, Colors.green),
      _sectionData(_stats['absent']!, Colors.red),
      _sectionData(_stats['justified']!, Colors.orange),
    ];
  }

  PieChartSectionData _sectionData(int value, Color color) {
    final percentage = _total > 0 ? (value / _total) * 100 : 0;
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '${percentage.toStringAsFixed(0)}%',
      radius: 50,
      titleStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 20,
      children: [
        _legendItem("Présent", Colors.green),
        _legendItem("Absent", Colors.red),
        _legendItem("Justifié", Colors.orange),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatTile(String label, int count, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
          child: Text(
            count.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
