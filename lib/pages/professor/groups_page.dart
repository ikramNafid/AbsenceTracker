import 'package:flutter/material.dart';
import 'students_by_group_page.dart';

class GroupsPage extends StatelessWidget {
  final String moduleName;
  final List<Map<String, dynamic>> groups;

  const GroupsPage({super.key, required this.moduleName, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Groupes du module $moduleName'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: groups.isEmpty
          ? const Center(
              child: Text(
                'Aucun groupe disponible',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: groups.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      // Naviguer vers la page des étudiants
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentsByGroupPage(
                            groupId: group['id'],
                            groupName: group['name'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      shadowColor: Colors.grey.shade400,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group,
                                size: 50, color: Colors.blue.shade700),
                            const SizedBox(height: 12),
                            Text(
                              group['name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (group['studentsCount'] != null)
                              Text(
                                '${group['studentsCount']} étudiants',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
