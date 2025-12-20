import 'package:flutter/material.dart';

class GestionFilieresPage extends StatelessWidget {
  const GestionFilieresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des filières')),
      body: const Center(child: Text('Liste / Import / Gestion des filières')),
    );
  }
}
