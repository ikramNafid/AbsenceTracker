import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ListeEtudiantsPage extends StatefulWidget {
  const ListeEtudiantsPage({super.key});

  @override
  State<ListeEtudiantsPage> createState() => _ListeEtudiantsPageState();
}

class _ListeEtudiantsPageState extends State<ListeEtudiantsPage> {
  List<Map<String, dynamic>> _etudiants = [];

  @override
  void initState() {
    super.initState();
    _fetchEtudiants();
  }

  Future<void> _fetchEtudiants() async {
    final students = await DatabaseHelper.instance.getStudents();
    setState(() => _etudiants = students);
  }

  Future<void> _showStudentForm({Map<String, dynamic>? student}) async {
    final firstNameController = TextEditingController(
      text: student?['firstName'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: student?['lastName'] ?? '',
    );
    final massarController = TextEditingController(
      text: student?['massar'] ?? '',
    );
    final groupController = TextEditingController(
      text: student?['groupName'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student == null ? 'Ajouter Étudiant' : 'Modifier Étudiant'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: massarController,
                decoration: const InputDecoration(labelText: 'Massar'),
              ),
              TextField(
                controller: groupController,
                decoration: const InputDecoration(labelText: 'Groupe'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'firstName': firstNameController.text,
                'lastName': lastNameController.text,
                'massar': massarController.text,
                'groupId': null,
                'email': '', // sera généré automatiquement
              };

              if (student == null) {
                await DatabaseHelper.instance.insertStudent(data);
              } else {
                await DatabaseHelper.instance.updateStudent(
                  student['id'],
                  data,
                );
              }

              Navigator.pop(context);
              _fetchEtudiants();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _fetchEtudiants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des étudiants'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showStudentForm(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEtudiants,
        child: _etudiants.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Aucun étudiant trouvé')),
                ],
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.blue.shade200,
                  ),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  dataTextStyle: const TextStyle(fontSize: 14),
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columns: const [
                    DataColumn(label: Text('Prénom')),
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Massar')),
                    DataColumn(label: Text('Groupe')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _etudiants.map((e) {
                    return DataRow(
                      cells: [
                        DataCell(Text(e['firstName'] ?? '')),
                        DataCell(Text(e['lastName'] ?? '')),
                        DataCell(Text(e['email'] ?? '')),
                        DataCell(Text(e['massar'] ?? '')),
                        DataCell(Text(e['groupName'] ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showStudentForm(student: e),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteStudent(e['id']),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
