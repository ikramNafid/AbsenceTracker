import 'package:flutter/material.dart';
import "../../database/database_helper.dart";
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

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
    final students = await DatabaseHelper.instance.getStudents();
    setState(() {
      _etudiants = students;
      _filteredEtudiants = students;
    });
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEtudiants = _etudiants.where((etudiant) {
        final fullName =
            '${etudiant['firstName']} ${etudiant['lastName']}'.toLowerCase();
        final email = etudiant['email']?.toLowerCase() ?? '';
        return fullName.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _fetchEtudiants();
  }

  Future<void> _showStudentForm({Map<String, dynamic>? student}) async {
    final firstNameController =
        TextEditingController(text: student?['firstName'] ?? '');
    final lastNameController =
        TextEditingController(text: student?['lastName'] ?? '');
    final emailController =
        TextEditingController(text: student?['email'] ?? '');
    final massarController =
        TextEditingController(text: student?['massar'] ?? '');

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
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: massarController,
                decoration: const InputDecoration(labelText: 'Massar'),
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
                'email': emailController.text,
                'massar': massarController.text,
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

  // ================= IMPORT CSV =================
  Future<void> _importCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();

      List<List<dynamic>> rows =
          const CsvToListConverter(fieldDelimiter: ';').convert(csvString);

      final headers = rows.first.map((e) => e.toString()).toList();
      final dataRows = rows.sublist(1);

      int count = 0;

      for (var row in dataRows) {
        final student = {
          'firstName': row[headers.indexOf('firstName')].toString(),
          'lastName': row[headers.indexOf('lastName')].toString(),
          'email': row[headers.indexOf('email')].toString(),
          'massar': row[headers.indexOf('password')].toString(),
          'groupId': null,
        };

        await DatabaseHelper.instance.insertStudent(student);
        count++;
      }

      _fetchEtudiants();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import réussi ✅ $count étudiants ajoutés')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur import CSV : $e')),
      );
    }
  }
  // =================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2), // 🔵 Bleu clair
        elevation: 2,
        title: const Text(
          'Gestion des étudiants',
          style: TextStyle(
            color: Colors.white, // ⚪ Titre blanc
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Importer CSV',
            onPressed: _importCSV,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher un étudiant...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredEtudiants.isEmpty
                  ? const Center(child: Text('Aucun étudiant trouvé'))
                  : ListView.builder(
                      itemCount: _filteredEtudiants.length,
                      itemBuilder: (context, index) {
                        final etudiant = _filteredEtudiants[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                                '${etudiant['firstName']} ${etudiant['lastName']}'),
                            subtitle: Text(etudiant['email'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () =>
                                      _showStudentForm(student: etudiant),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteStudent(etudiant['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un étudiant'),
                onPressed: () => _showStudentForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2), // même bleu clair
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
