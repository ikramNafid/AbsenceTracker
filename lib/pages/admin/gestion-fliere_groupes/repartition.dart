import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class RepartitionPage extends StatefulWidget {
  const RepartitionPage({super.key});

  @override
  State<RepartitionPage> createState() => _RepartitionPageState();
}

class _RepartitionPageState extends State<RepartitionPage> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filieres = [];
  Map<int, int?> selectedFiliereIds = {}; // studentId -> filiereId

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stus = await DatabaseHelper.instance.getStudents();
      final fils = await DatabaseHelper.instance.getFilieres();

      setState(() {
        students = stus;
        filieres = fils;
        for (var s in students) {
          selectedFiliereIds[s['id']] = s['filiereId']; // récupère l'id correct
        }
      });
    } catch (e) {
      print("Erreur lors du chargement des données : $e");
    }
  }

  Future<void> _assignFiliere(int studentId, int filiereId) async {
    try {
      final groups =
          await DatabaseHelper.instance.getGroupsByFiliere(filiereId);
      if (groups.isNotEmpty) {
        final groupId = groups.first['id'];
        await DatabaseHelper.instance
            .updateStudent(studentId, {'groupId': groupId});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Affectation réussie')),
        );
        _loadData(); // recharger la liste après affectation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucun groupe disponible pour cette filière')),
        );
      }
    } catch (e) {
      print("Erreur lors de l'affectation : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'affectation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Répartition des étudiants par filière'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title:
                        Text('${student['firstName']} ${student['lastName']}'),
                    subtitle: Text(student['email'] ?? ''),
                    trailing: SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: selectedFiliereIds[student['id']],
                              hint: const Text('Filière'),
                              items: filieres.map((f) {
                                return DropdownMenuItem<int>(
                                  value: f['id'],
                                  child: Text(f['nom']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedFiliereIds[student['id']] = value!;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: selectedFiliereIds[student['id']] != null
                                ? () => _assignFiliere(student['id'],
                                    selectedFiliereIds[student['id']]!)
                                : null,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
