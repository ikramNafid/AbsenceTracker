import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../../database/database_helper.dart';
import '../../widgets/gestion_page.dart'; // Assurez-vous que le chemin est correct

class GestionCoordinateursPage extends StatefulWidget {
  const GestionCoordinateursPage({super.key});

  @override
  State<GestionCoordinateursPage> createState() =>
      _GestionCoordinateursPageState();
}

class _GestionCoordinateursPageState extends State<GestionCoordinateursPage> {
  List<Map<String, dynamic>> _coordinateurs = [];
  List<Map<String, dynamic>> _filteredCoordinateurs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCoordinateurs();
    _searchController.addListener(_onSearch);
  }

  // ================= FETCH =================
  Future<void> _fetchCoordinateurs() async {
    final data = await DatabaseHelper.instance.getCoordinateurs();
    setState(() {
      _coordinateurs = data;
      _filteredCoordinateurs = data;
    });
  }

  // ================= SEARCH =================
  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredCoordinateurs = _coordinateurs.where((c) {
        final fullName = '${c['firstName']} ${c['lastName']}'.toLowerCase();
        final email = (c['email'] ?? '').toLowerCase();
        return fullName.contains(q) || email.contains(q);
      }).toList();
    });
  }

  // ================= DELETE =================
  Future<void> _deleteCoordinateur(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    _fetchCoordinateurs();
  }

  // ================= FORM =================
  Future<void> _showCoordinateurForm({Map<String, dynamic>? coord}) async {
    final firstName = TextEditingController(text: coord?['firstName'] ?? '');
    final lastName = TextEditingController(text: coord?['lastName'] ?? '');
    final email = TextEditingController(text: coord?['email'] ?? '');
    final password = TextEditingController(text: coord?['password'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          coord == null ? 'Ajouter Coordinateur' : 'Modifier Coordinateur',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstName,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: password,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
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
                'firstName': firstName.text,
                'lastName': lastName.text,
                'email': email.text,
                'password': password.text,
                'roleId': 3, // ✅ Coordinateur
              };

              if (coord == null) {
                await DatabaseHelper.instance.insertUser(data);
              } else {
                await DatabaseHelper.instance.updateUser(coord['id'], data);
              }

              if (mounted) Navigator.pop(context);
              _fetchCoordinateurs();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ================= IMPORT CSV =================
  Future<void> _importCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) return;

    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows =
          const CsvToListConverter(fieldDelimiter: ',').convert(content);

      if (rows.isEmpty) return;

      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final requiredColumns = ['firstName', 'lastName', 'email', 'password'];

      for (var col in requiredColumns) {
        if (!headers.contains(col)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Colonne manquante dans le CSV : $col')),
          );
          return;
        }
      }

      for (var row in rows.skip(1)) {
        if (row.length < headers.length) continue;
        await DatabaseHelper.instance.insertUser({
          'firstName': row[headers.indexOf('firstName')].toString(),
          'lastName': row[headers.indexOf('lastName')].toString(),
          'email': row[headers.indexOf('email')].toString(),
          'password': row[headers.indexOf('password')].toString(),
          'roleId': 3, // Coordinateur
        });
      }
      _fetchCoordinateurs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'importation : $e')),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return GestionPage(
      title: 'Gestion des coordinateurs',
      searchHint: 'Rechercher un coordinateur...',
      searchController: _searchController,
      items: _filteredCoordinateurs,
      onImportCSV: _importCSV,
      onAdd: () => _showCoordinateurForm(),
      onEdit: (c) => _showCoordinateurForm(coord: c),
      onDelete: (id) => _deleteCoordinateur(id),
    );
  }
}
