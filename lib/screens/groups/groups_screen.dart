import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group_model.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GroupProvider>().fetchGroups());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final list = provider.groups;

    return Scaffold(
      appBar: AppBar(title: const Text('Groupes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher un groupe',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _query.isEmpty
                  ? provider.fetchGroups()
                  : provider.searchGroups(_query),
              builder: (context, snapshot) {
                final items = _query.isEmpty
                    ? list
                    : (snapshot.data as List<GroupModel>? ?? []);
                if (items.isEmpty) {
                  return const Center(child: Text('Aucun groupe'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final g = items[i];
                    return ListTile(
                      title: Text(g.name),
                      subtitle: Text(g.filiere ?? '—'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/students',
                        arguments: g,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameController = TextEditingController();
          final filiereController = TextEditingController();
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Ajouter un groupe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: filiereController,
                    decoration: const InputDecoration(labelText: 'Filière'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          );
          if (ok == true) {
            await context.read<GroupProvider>().addGroup(
              GroupModel(
                name: nameController.text.trim(),
                filiere: filiereController.text.trim(),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
