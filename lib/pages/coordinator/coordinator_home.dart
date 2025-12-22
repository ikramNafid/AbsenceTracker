import 'package:flutter/material.dart';

class CoordinatorHome extends StatelessWidget {
  const CoordinatorHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace Coordinateur')),
      body: const Center(child: Text('Statistiques de la filière')),
    );
  }
}
