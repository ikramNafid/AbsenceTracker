import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../../database/database_helper.dart';
import '../../widgets/gestion_page.dart';

class GestionEtudiantsPage extends StatefulWidget {
  const GestionEtudiantsPage({super.key});

  @override
  State<GestionEtudiantsPage> createState() => _GestionEtudiantsPageState();
}

class _GestionEtudiantsPageState extends State<GestionEtudiantsPage> {
  List<Map<String, dynamic>> _etudiants = [];
  List<Map<String, dynamic>> _filteredEtudiants = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEtudiants();
    _searchController.addListener(_onSearch);
  }

  Future<void> _fetchEtudiants() async {
    final data = await DatabaseHelper.instance.getStudents();
    setState(() {
      _etudiants = data;
      _filteredEtudiants = data;
    });
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredEtudiants = _etudiants.where((e) {
        return '${e['firstName']} ${e['lastName']}'.toLowerCase().contains(q) ||
            (e['email'] ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _fetchEtudiants();
  }

  Future<void> _showStudentForm({Map<String, dynamic>? student}) async {
    final firstName = TextEditingController(text: student?['firstName'] ?? '');
    final lastName = TextEditingController(text: student?['lastName'] ?? '');
    final email = TextEditingController(text: student?['email'] ?? '');
    final massar = TextEditingController(text: student?['massar'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student == null ? 'Ajouter Étudiant' : 'Modifier Étudiant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: firstName,
                decoration: const InputDecoration(labelText: 'Prénom')),
            TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Nom')),
            TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: massar,
                decoration: const InputDecoration(labelText: 'Massar')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'firstName': firstName.text,
                'lastName': lastName.text,
                'email': email.text,
                'massar': massar.text,
                'groupId': null,
              };

              if (student == null) {
                await DatabaseHelper.instance.insertStudent(data);
              } else {
                await DatabaseHelper.instance
                    .updateStudent(student['id'], data);
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

  Future<void> _importCSV() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null) return;

    final file = File(result.files.single.path!);
    final rows = const CsvToListConverter(fieldDelimiter: ';')
        .convert(await file.readAsString());

    final headers = rows.first.map((e) => e.toString()).toList();

    for (var row in rows.skip(1)) {
      await DatabaseHelper.instance.insertStudent({
        'firstName': row[headers.indexOf('firstName')].toString(),
        'lastName': row[headers.indexOf('lastName')].toString(),
        'email': row[headers.indexOf('email')].toString(),
        'massar': row[headers.indexOf('password')].toString(),
        'groupId': null,
      });
    }

    _fetchEtudiants();
  }

  @override
  Widget build(BuildContext context) {
    return GestionPage(
      title: 'Gestion des étudiants',
      searchHint: 'Rechercher un étudiant...',
      searchController: _searchController,
      items: _filteredEtudiants,
      onImportCSV: _importCSV,
      onAdd: () => _showStudentForm(),
      onEdit: (e) => _showStudentForm(student: e),
      onDelete: _deleteStudent,
    );
  }
}
