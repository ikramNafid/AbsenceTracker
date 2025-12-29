import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import 'students_page.dart';

class GroupsPage extends StatefulWidget {
  final String moduleName;
  const GroupsPage({super.key, required this.moduleName});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

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
    final data =
        await DatabaseHelper.instance.getGroupsByModuleName(widget.moduleName);
    setState(() {
      groups = data;
      filteredGroups = data;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.moduleName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // En-tête incurvé avec barre de recherche
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: _filterGroups,
              decoration: InputDecoration(
                hintText: 'Rechercher un groupe...',
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredGroups.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      return _buildGroupCard(context, group);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.groups_rounded, color: Colors.blue.shade700),
        ),
        title: Text(
          group['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Voir la liste des étudiants",
          style: TextStyle(color: Colors.blue.shade600, fontSize: 13),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Aucun groupe trouvé",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
