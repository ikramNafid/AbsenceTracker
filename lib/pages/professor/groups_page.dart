import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import 'students_page.dart';

class GroupsPage extends StatefulWidget {
  final String moduleName;
  const GroupsPage({super.key, required this.moduleName});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

// ... (imports existants)

class _GroupsPageState extends State<GroupsPage> {
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> filteredGroups = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() async {
    // Récupère les groupes liés spécifiquement à ce module
    final data =
        await DatabaseHelper.instance.getGroupsByModuleName(widget.moduleName);
    setState(() {
      groups = data;
      filteredGroups = data; // Initialiser aussi la liste filtrée
    });
  }

  void _filterGroups(String query) {
    setState(() {
      filteredGroups = groups
          .where((g) =>
              g['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groupes : ${widget.moduleName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterGroups,
              decoration: InputDecoration(
                labelText: 'Rechercher un groupe',
                prefixIcon: const Icon(Icons.group),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: filteredGroups.isEmpty
                ? const Center(
                    child: Text("Aucun groupe trouvé pour ce module"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading:
                              const CircleAvatar(child: Icon(Icons.people)),
                          title: Text(group['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              const Text("Cliquez pour voir les étudiants"),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentsPage(
                                  groupId: group['id'],
                                  groupName: group['name'],
                                ),
                              ),
                            );
                          },
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
