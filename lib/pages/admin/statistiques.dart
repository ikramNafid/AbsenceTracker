import 'package:flutter/material.dart';

class Statistiques extends StatelessWidget {
  const Statistiques({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STATISTIQUES GÉNÉRALES')),
      body: const Center(child: Text('Liste / Import / Gestion des étudiants')),
    );
  }
}
