import 'package:flutter/material.dart';
import 'package:absence_tracker/database/database_helper.dart';
import '../students/student_list_page.dart';

class ModuleDetailPage extends StatefulWidget {
  final Map<String, dynamic> module;

  const ModuleDetailPage({Key? key, required this.module}) : super(key: key);

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  late Future<List<Map<String, dynamic>>> _groups;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    _groups = DatabaseHelper.instance.getGroupsByModule(widget.module['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.module['name'])),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _groups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun groupe associé'));
          }

          final groups = snapshot.data!;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(group['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentsListPage(groupId: group['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
