import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class DistributeStudentsByGroupPage extends StatefulWidget {
  final int filiereId;

  const DistributeStudentsByGroupPage({
    super.key,
    required this.filiereId,
  });

  @override
  State<DistributeStudentsByGroupPage> createState() =>
      _DistributeStudentsByGroupPageState();
}

class _DistributeStudentsByGroupPageState
    extends State<DistributeStudentsByGroupPage> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> groups = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);

    final db = DatabaseHelper.instance;
    final s = await db.getStudentsByFiliere(widget.filiereId);
    final g = await db.getGroupsByFiliere(widget.filiereId);

    setState(() {
      students = s;
      groups = g;
      loading = false;
    });
  }

  String? _getGroupName(int? groupId) {
    if (groupId == null) return null;
    final g = groups.firstWhere(
      (grp) => grp['id'] == groupId,
      orElse: () => {},
    );
    return g.isNotEmpty ? g['name'] : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Répartition des étudiants par groupe"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(child: Text("Aucun étudiant trouvé"))
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final int? groupId = student['groupId'];
                    final String? groupName = _getGroupName(groupId);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${student['firstName']} ${student['lastName']}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              groupName != null
                                  ? "Groupe actuel : $groupName"
                                  : "Non affecté",
                              style: TextStyle(
                                color: groupName != null
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<int>(
                              value: groups.any((g) => g['id'] == groupId)
                                  ? groupId
                                  : null,
                              hint: const Text("Choisir un groupe"),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: groups.map((g) {
                                return DropdownMenuItem<int>(
                                  value: g['id'],
                                  child: Text(g['name']),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                if (value == null) return;

                                await DatabaseHelper.instance
                                    .assignStudentToGroup(
                                  student['id'],
                                  value,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Étudiant affecté au groupe avec succès"),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );

                                _loadData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
