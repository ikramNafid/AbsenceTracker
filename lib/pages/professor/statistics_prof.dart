import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsProf extends StatelessWidget {
  const StatisticsProf({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Taux d’absence par module',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 200, child: ModuleBarChart()),
              const SizedBox(height: 20),
              const Text('Taux d’absence par jour',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 200, child: DayBarChart()),
              const SizedBox(height: 20),
              const Text('Histogramme des présences',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 200, child: AttendanceHistogram()),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Module Bar Chart ----------------
class ModuleBarChart extends StatelessWidget {
  const ModuleBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = {
      'Mathématiques': 10,
      'Informatique': 5,
      'Physique': 8,
    };

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < data.keys.length) {
                  return Text(data.keys.elementAt(index));
                }
                return const Text('');
              },
            ),
          ),
        ),
        barGroups: data.entries
            .map((e) => BarChartGroupData(
                  x: data.keys.toList().indexOf(e.key),
                  barRods: [
                    BarChartRodData(toY: e.value.toDouble(), color: Colors.blue)
                  ],
                ))
            .toList(),
      ),
    );
  }
}

// ---------------- Day Bar Chart ----------------
class DayBarChart extends StatelessWidget {
  const DayBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = {
      'Lun': 5,
      'Mar': 8,
      'Mer': 3,
      'Jeu': 7,
      'Ven': 2,
    };

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < data.keys.length) {
                  return Text(data.keys.elementAt(index));
                }
                return const Text('');
              },
            ),
          ),
        ),
        barGroups: data.entries
            .map((e) => BarChartGroupData(
                  x: data.keys.toList().indexOf(e.key),
                  barRods: [
                    BarChartRodData(
                        toY: e.value.toDouble(), color: Colors.orange)
                  ],
                ))
            .toList(),
      ),
    );
  }
}

// ---------------- Attendance Histogram ----------------
class AttendanceHistogram extends StatelessWidget {
  const AttendanceHistogram({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [8, 10, 6, 12, 9, 7]; // présences par séance

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('S${value.toInt() + 1}'),
            ),
          ),
        ),
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(toY: data[index].toDouble(), color: Colors.green)
          ]);
        }),
      ),
    );
  }
}
