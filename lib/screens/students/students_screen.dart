import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../models/group_model.dart';
import '../../models/student_model.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final group = ModalRoute.of(context)!.settings.arguments as GroupModel?;
    Future.microtask(
      () => context.read<StudentProvider>().fetchStudents(groupId: group?.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final group = ModalRoute.of(context)!.settings.arguments as GroupModel?;
    final list = provider.students;

    return Scaffold(
      appBar: AppBar(
        title: Text(group != null ? 'Étudiants • ${group.name}' : 'Étudiants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Chercher un étudiant',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _query.isEmpty
                  ? provider.fetchStudents(groupId: group?.id)
                  : provider.search(_query, groupId: group?.id),
              builder: (context, snapshot) {
                final items = _query.isEmpty
                    ? list
                    : (snapshot.data as List<StudentModel>? ?? []);
                if (items.isEmpty) {
                  return const Center(child: Text('Aucun étudiant'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final s = items[i];
                    return ListTile(
                      title: Text(s.fullName),
                      subtitle: Text(s.massar),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/studentDetail',
                        arguments: s,
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
          final fn = TextEditingController();
          final ln = TextEditingController();
          final massar = TextEditingController();
          final email = TextEditingController();
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Ajouter un étudiant'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fn,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),
                  TextField(
                    controller: ln,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: massar,
                    decoration: const InputDecoration(labelText: 'CNE/Massar'),
                  ),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email'),
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
            final group =
                ModalRoute.of(context)!.settings.arguments as GroupModel?;
            await context.read<StudentProvider>().addStudent(
              StudentModel(
                groupId: group?.id,
                massar: massar.text.trim(),
                firstName: fn.text.trim(),
                lastName: ln.text.trim(),
                email: email.text.trim().isEmpty ? null : email.text.trim(),
              ),
            );
          }
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
