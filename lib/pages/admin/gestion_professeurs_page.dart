import 'package:flutter/material.dart';
import "../../widgets/gestion_page.dart";

class GestionProfesseursPage extends StatelessWidget {
  const GestionProfesseursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionPage(
      pageTitle: 'Gestion des professeurs',
      headerText: 'Gérer vos professeurs : liste, importation et édition',
      actions: [
        GestionAction(
          title: 'Liste des professeurs',
          icon: Icons.list,
          color: Colors.blue,
          onTap: () {
            // action liste
          },
        ),
        GestionAction(
          title: 'Importer CSV',
          icon: Icons.upload_file,
          color: Colors.green,
          onTap: () {
            // action import
          },
        ),
        GestionAction(
          title: 'Gérer professeurs',
          icon: Icons.edit,
          color: Colors.orange,
          onTap: () {
            // action gestion
          },
        ),
        GestionAction(
          title: 'Rechercher',
          icon: Icons.search,
          color: Colors.purple,
          onTap: () {
            // action recherche
          },
        ),
      ],
    );
  }
}
