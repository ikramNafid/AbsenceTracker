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

  // ================= FETCH =================
  Future<void> _fetchEtudiants() async {
    // Assurez-vous que getStudents() est défini dans DatabaseHelper
    final data = await DatabaseHelper.instance.getStudents();
    setState(() {
      _etudiants = data;
      _filteredEtudiants = data;
    });
  }

  // ================= SEARCH =================
  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredEtudiants = _etudiants.where((e) {
        final fullName = '${e['firstName']} ${e['lastName']}'.toLowerCase();
        final email = (e['email'] ?? '').toLowerCase();
        return fullName.contains(q) || email.contains(q);
      }).toList();
    });
  }

  // ================= DELETE =================
  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _fetchEtudiants();
  }

  // ================= FORM =================
  Future<void> _showStudentForm({Map<String, dynamic>? student}) async {
    final firstName = TextEditingController(text: student?['firstName'] ?? '');
    final lastName = TextEditingController(text: student?['lastName'] ?? '');
    final email = TextEditingController(text: student?['email'] ?? '');
    final massar = TextEditingController(text: student?['massar'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student == null ? 'Ajouter Étudiant' : 'Modifier Étudiant'),
        content: SingleChildScrollView(
          child: Column(
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
                  decoration: const InputDecoration(labelText: 'Code Massar')),
            ],
          ),
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
                'groupId': student?['groupId'], // On garde le groupe actuel
              };

              if (student == null) {
                await DatabaseHelper.instance.insertStudent(data);
              } else {
                await DatabaseHelper.instance
                    .updateStudent(student['id'], data);
              }

              if (mounted) Navigator.pop(context);
              _fetchEtudiants();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ================= IMPORT CSV =================
  Future<void> _importCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();

      // Vérifiez si votre CSV utilise ',' ou ';'
      List<List<dynamic>> rows =
          const CsvToListConverter(fieldDelimiter: ';').convert(csvString);

      if (rows.isEmpty) return;
      final headers = rows.first.map((e) => e.toString().trim()).toList();

      for (var row in rows.skip(1)) {
        if (row.length < headers.length) continue;
        await DatabaseHelper.instance.insertStudent({
          'firstName': row[headers.indexOf('firstName')].toString(),
          'lastName': row[headers.indexOf('lastName')].toString(),
          'email': row[headers.indexOf('email')].toString(),
          'massar': row[headers.indexOf('password')]
              .toString(), // Souvent stocké dans password au début
          'groupId': null,
        });
      }

      _fetchEtudiants();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Importation réussie ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'import : $e')),
        );
      }
    }
  }

  // ================= UI =================
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
      onDelete: (id) => _deleteStudent(id),
    );
  }
}
