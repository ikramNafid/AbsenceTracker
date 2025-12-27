// import 'package:flutter/material.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Paramètres"),
//         centerTitle: true,
//       ),

//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [

//           // 🔔 Notifications
//           ListTile(
//             leading: const Icon(Icons.notifications),
//             title: const Text("Notifications"),
//             subtitle: const Text("Activer / désactiver les notifications"),
//             trailing: Switch(
//               value: true,
//               onChanged: (value) {
//                 // plus tard : sauvegarder dans SQLite
//               },
//             ),
//           ),

//           const Divider(),

//           // 🌗 Mode sombre
//           ListTile(
//             leading: const Icon(Icons.dark_mode),
//             title: const Text("Mode sombre"),
//             subtitle: const Text("Changer le thème"),
//             trailing: Switch(
//               value: false,
//               onChanged: (value) {
//                 // plus tard : gestion du thème
//               },
//             ),
//           ),

//           const Divider(),

//           // 🔒 Sécurité
//           ListTile(
//             leading: const Icon(Icons.lock),
//             title: const Text("Sécurité"),
//             subtitle: const Text("Modifier mot de passe"),
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text("Fonction bientôt disponible"),
//                 ),
//               );
//             },
//           ),

//           const Divider(),

//           // ℹ️ À propos
//           ListTile(
//             leading: const Icon(Icons.info),
//             title: const Text("À propos"),
//             subtitle: const Text("Absence Tracker - Version 1.0"),
//             onTap: () {
//               showAboutDialog(
//                 context: context,
//                 applicationName: "Absence Tracker",
//                 applicationVersion: "1.0.0",
//                 applicationIcon: const Icon(Icons.school),
//               );
//             },
//           ),

//           const Divider(),

//           // 🚪 Déconnexion
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text(
//               "Déconnexion",
//               style: TextStyle(color: Colors.red),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔔 Notifications
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            subtitle: const Text("Activer / désactiver les notifications"),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // plus tard : sauvegarder dans SQLite
              },
            ),
          ),

          const Divider(),

          // 🔒 Sécurité
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Sécurité"),
            subtitle: const Text("Modifier mot de passe"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fonction bientôt disponible"),
                ),
              );
            },
          ),

          const Divider(),

          // 🌗 Mode sombre
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Mode sombre"),
            subtitle: const Text("Changer le thème de l'application"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                // Appel de la fonction de changement de thème passée en paramètre
                onThemeChanged(value);
              },
            ),
          ),
          const Divider(),
          // ℹ️ À propos
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("À propos"),
            subtitle: const Text("Absence Tracker - Version 1.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Absence Tracker",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.school),
              );
            },
          ),
          const Divider(),
          // 🚪 Déconnexion
        ],
      ),
    );
  }
}
