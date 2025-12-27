import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ModuleManagementPage extends StatefulWidget {
  final int filiereId;
  const ModuleManagementPage({super.key, required this.filiereId});

  @override
  State<ModuleManagementPage> createState() => _ModuleManagementPageState();
}

class _ModuleManagementPageState extends State<ModuleManagementPage> {
  final _nameController = TextEditingController();
  final _semesterController = TextEditingController();

  Future<void> _addModule() async {
    if (_nameController.text.isEmpty || _semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remplis le nom et le semestre du module'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final moduleId = await DatabaseHelper.instance.insertModule({
      'name': _nameController.text,
      'semester': _semesterController.text,
    });

    if (moduleId == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de l'ajout du module"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Module ajouté avec succès"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un module"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Informations du module",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nom du module",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.book, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _semesterController,
                  decoration: InputDecoration(
                    labelText: "Semestre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.school, color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _addModule,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Ajouter le module",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
