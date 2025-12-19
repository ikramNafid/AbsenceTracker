import 'package:flutter/material.dart';
import "../../widgets/gestion_page.dart"; // le widget réutilisable

class GestionCoordinateursPage extends StatelessWidget {
  const GestionCoordinateursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestionPage(
      pageTitle: 'Gestion des coordinateurs',
      headerText: 'Gérer vos coordinateurs : liste, importation et édition',
      actions: [
        GestionAction(
          title: 'Liste des coordinateurs',
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
          title: 'Gérer coordinateurs',
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
