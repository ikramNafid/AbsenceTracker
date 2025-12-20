import 'package:flutter/material.dart';

class ProfHome extends StatelessWidget {
  const ProfHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace Professeur')),
      body: const Center(child: Text('Marquage des absences')),
    );
  }
}
