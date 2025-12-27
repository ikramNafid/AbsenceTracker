import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../../database/database_helper.dart';
import '../../widgets/gestion_page.dart';

class GestionProfesseursPage extends StatefulWidget {
  const GestionProfesseursPage({super.key});

  @override
  State<GestionProfesseursPage> createState() => _GestionProfesseursPageState();
}

class _GestionProfesseursPageState extends State<GestionProfesseursPage> {
  List<Map<String, dynamic>> _profs = [];
  List<Map<String, dynamic>> _filtered = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchController.addListener(_search);
  }

  // ================= FETCH =================
  Future<void> _fetch() async {
    // Récupère les utilisateurs ayant le rôle de professeur (roleId: 2)
    final data = await DatabaseHelper.instance.getProfesseurs();
    setState(() {
      _profs = data;
      _filtered = data;
    });
  }

  // ================= SEARCH =================
  void _search() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _profs.where((p) {
        final fullName = '${p['firstName']} ${p['lastName']}'.toLowerCase();
        final email = (p['email'] ?? '').toLowerCase();
        return fullName.contains(q) || email.contains(q);
      }).toList();
    });
  }

  // ================= DELETE =================
  Future<void> _delete(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    _fetch();
  }

  // ================= FORM =================
  Future<void> _form({Map<String, dynamic>? prof}) async {
    final fn = TextEditingController(text: prof?['firstName'] ?? '');
    final ln = TextEditingController(text: prof?['lastName'] ?? '');
    final em = TextEditingController(text: prof?['email'] ?? '');
    final pw = TextEditingController(text: prof?['password'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          prof == null ? 'Ajouter Professeur' : 'Modifier Professeur',
        ),
        content: SingleChildScrollView(
          child: Column(
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
                controller: em,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: pw,
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
                'firstName': fn.text,
                'lastName': ln.text,
                'email': em.text,
                'password': pw.text,
                'roleId': 2, // ✅ Rôle Professeur
              };

              if (prof == null) {
                await DatabaseHelper.instance.insertUser(data);
              } else {
                await DatabaseHelper.instance.updateUser(prof['id'], data);
              }

              if (mounted) Navigator.pop(context);
              _fetch();
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

    if (result == null || result.files.single.path == null) return;

    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      // Utilise souvent la virgule ou le point-virgule selon l'export Excel
      final rows =
          const CsvToListConverter(fieldDelimiter: ';').convert(content);
      if (rows.length <= 1) return;

      final headers = rows.first.map((e) => e.toString().trim()).toList();

      for (var row in rows.skip(1)) {
        if (row.length < headers.length) continue;
        try {
          await DatabaseHelper.instance.insertUser({
            'firstName': row[headers.indexOf('firstName')].toString(),
            'lastName': row[headers.indexOf('lastName')].toString(),
            'email': row[headers.indexOf('email')].toString(),
            'password': row[headers.indexOf('password')].toString(),
            'roleId': 2,
          });
        } catch (_) {
          // Ignore les erreurs individuelles (ex: doublons d'email)
        }
      }

      _fetch();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import des professeurs réussi ✅')),
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
      title: 'Gestion des professeurs',
      searchHint: 'Rechercher un professeur...',
      searchController: _searchController,
      items: _filtered,
      onImportCSV: _importCSV,
      onAdd: () => _form(),
      onEdit: (p) => _form(prof: p),
      onDelete: (id) => _delete(id),
    );
  }
}
