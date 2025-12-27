import 'package:flutter/material.dart';

class AffectProfPage extends StatefulWidget {
  const AffectProfPage({super.key});

  @override
  State<AffectProfPage> createState() => _AffectProfPageState();
}

class _AffectProfPageState extends State<AffectProfPage> {
  String? selectedProf;
  String? selectedModule;

  final List<String> profs = ["Prof Karim", "Prof Nadia"];
  final List<String> modules = ["Java", "Maths", "Réseaux"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Affectation professeurs"),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Professeur"),
              items: profs
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => selectedProf = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Module"),
              items: modules
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => selectedModule = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Affecter"),
            )
          ],
        ),
      ),
    );
  }
}
