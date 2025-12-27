// import 'package:absence_tracker/pages/student/notifications_page.dart';
// import 'package:absence_tracker/pages/student/student_history_page.dart';
// import 'package:absence_tracker/pages/student/validate_presence_qr.dart';
// import 'package:absence_tracker/widgets/homeButton.dart';
// import 'package:flutter/material.dart';

// class StudentHomePage extends StatelessWidget {
//   final String studentName;
//   final String groupName;

//   const StudentHomePage({
//     super.key,
//     required this.studentName,
//     required this.groupName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Espace Étudiant"),
//         centerTitle: true,
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             // Message de bienvenue
//             Text(
//               "Bonjour, $studentName ",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             SizedBox(height: 8),

//             //  Groupe
//             Text(
//               "Groupe : $groupName",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[700],
//               ),
//             ),

//             SizedBox(height: 30),

//             // Historique
//             HomeButton(
//               icon: Icons.history,
//               title: "Mes absences",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => StudentHistoryPage(studentId: 1,),
//                   ),
//                 );
//               },
//             ),

//             // Notifications
//             HomeButton(
//               icon: Icons.notifications,
//               title: "Notifications",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const NotificationsPage(),
//                   ),
//                 );
//               },
//             ),

//             // QR Code
//             HomeButton(
//               icon: Icons.qr_code_scanner,
//               title: "Valider ma présence",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         ValidatePresenceQRPage(studentId: 1),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:absence_tracker/widgets/homeButton.dart';
// import 'package:absence_tracker/pages/student/notifications_page.dart';
// import 'package:absence_tracker/pages/student/student_history_page.dart';
// import 'package:absence_tracker/pages/student/validate_presence_qr.dart';
// import 'package:absence_tracker/pages/student/profile_page.dart';

// class StudentHomePage extends StatelessWidget {
//   final String studentName;
//   final String groupName;
//   final int studentId;

//   const StudentHomePage({
//     super.key,
//     required this.studentName,
//     required this.groupName,
//     required this.studentId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Espace Étudiant"),
//         centerTitle: true,
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             // 👤 Infos étudiant
//             Text(
//               "Bonjour, $studentName",
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 5),

//             Text(
//               "Groupe : $groupName",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[700],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // 🔲 Boutons
//             Expanded(
//               child: ListView(
//                 children: [

//                   // 👤 Profil
//                   HomeButton(
//                     icon: Icons.person,
//                     title: "Mon profil",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ProfilePage(studentId: studentId),
//                         ),
//                       );
//                     },
//                   ),

//                   // 🔔 Notifications
//                   HomeButton(
//                     icon: Icons.notifications,
//                     title: "Notifications",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const NotificationsPage(),
//                         ),
//                       );
//                     },
//                   ),

//                   // 📸 Scanner présence
//                   // QR Code
//                   HomeButton(
//                     icon: Icons.qr_code_scanner,
//                     title: "Valider ma présence",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               ValidatePresenceQRPage(studentId: 1),
//                         ),
//                       );
//                     },
//                   ),

//                   // 📊 Mes absences
//       // Historique
//                   HomeButton(
//                     icon: Icons.history,
//                     title: "Mes absences",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => StudentHistoryPage(studentId: 1,),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:absence_tracker/widgets/homeButton.dart';
import 'package:absence_tracker/pages/student/notifications_page.dart';
import 'package:absence_tracker/pages/student/student_history_page.dart';
import 'package:absence_tracker/pages/student/validate_presence_qr.dart';
import 'package:absence_tracker/pages/student/profile_page.dart';
import 'package:absence_tracker/pages/student/settings_page.dart';
import 'package:absence_tracker/pages/auth/login_page.dart';

class StudentHomePage extends StatelessWidget {
  final String studentName;
  final String groupName;
  final int studentId;
  final Function(bool) onThemeChanged; // Requis pour les réglages
  final bool isDarkMode; // Requis pour les réglages

  const StudentHomePage({
    super.key,
    required this.studentName,
    required this.groupName,
    required this.studentId,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔵 DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 🧑 HEADER
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text(studentName),
              accountEmail: Text("Groupe : $groupName"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
            ),

            // 👤 Profil
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Mon profil"),
              // Exemple pour le bouton dans le corps de la page ou le Drawer
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      userData: {
                        'id': studentId,
                        'firstName': studentName
                            .split(' ')[0], // Découpage simple pour l'exemple
                        'lastName': studentName.contains(' ')
                            ? studentName.split(' ')[1]
                            : '',
                        'email':
                            "etudiant@institution.ma", // À récupérer de votre DB si possible
                        'massar': "N/A", // Idem
                        'groupName': groupName,
                        'filiere': "Génie Informatique",
                      },
                    ),
                  ),
                );
              },
            ),

            // 🔔 Notifications
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );
              },
            ),

            // 📸 Scanner
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text("Valider présence"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ValidatePresenceQRPage(studentId: studentId),
                  ),
                );
              },
            ),

            // 📊 Absences
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Mes absences"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentHistoryPage(studentId: studentId),
                  ),
                );
              },
            ),

            const Divider(),

            // ⚙️ Paramètres
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Paramètres"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      onThemeChanged: onThemeChanged,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              },
            ),
            const Divider(),

            // 🚪 Déconnexion (optionnel)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Déconnexion"),
              // Dans le ListTile de déconnexion de StudentHomePage
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, // Efface tout l'historique de navigation
                );
              },
            ),
          ],
        ),
      ),

      // 🔵 APPBAR
      appBar: AppBar(
        title: const Text("Espace Étudiant"),
        centerTitle: true,
      ),

      // 🔵 BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bonjour, $studentName",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Groupe : $groupName",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  HomeButton(
                    icon: Icons.person,
                    title: "Mon profil",
                    // Exemple pour le bouton dans le corps de la page ou le Drawer
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(
                            userData: {
                              'id': studentId,
                              'firstName': studentName.split(
                                  ' ')[0], // Découpage simple pour l'exemple
                              'lastName': studentName.contains(' ')
                                  ? studentName.split(' ')[1]
                                  : '',
                              'email':
                                  "etudiant@institution.ma", // À récupérer de votre DB si possible
                              'massar': "N/A", // Idem
                              'groupName': groupName,
                              'filiere': "Génie Informatique",
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  HomeButton(
                    icon: Icons.notifications,
                    title: "Notifications",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  HomeButton(
                    icon: Icons.qr_code_scanner,
                    title: "Valider ma présence",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ValidatePresenceQRPage(studentId: studentId),
                        ),
                      );
                    },
                  ),
                  HomeButton(
                    icon: Icons.history,
                    title: "Mes absences",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StudentHistoryPage(studentId: studentId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:absence_tracker/widgets/homeButton.dart';
// import 'package:absence_tracker/pages/student/notifications_page.dart';
// import 'package:absence_tracker/pages/student/student_history_page.dart';
// import 'package:absence_tracker/pages/student/validate_presence_qr.dart';
// import 'package:absence_tracker/pages/student/profile_page.dart';
// import 'package:absence_tracker/pages/student/settings_page.dart';

// class StudentHomePage extends StatelessWidget {
//   final String studentName;
//   final String groupName;
//   final int studentId;
//   final Function(bool) onThemeChanged; // Requis pour les réglages
//   final bool isDarkMode; // Requis pour les réglages

//   const StudentHomePage({
//     super.key,
//     required this.studentName,
//     required this.groupName,
//     required this.studentId,
//     required this.onThemeChanged,
//     required this.isDarkMode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               decoration: const BoxDecoration(color: Colors.blue),
//               accountName: Text(studentName),
//               accountEmail: Text("Groupe : $groupName"),
//               currentAccountPicture: const CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(Icons.person, size: 40, color: Colors.blue),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text("Mon profil"),
//               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(studentId: studentId))),
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text("Paramètres"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => SettingsPage(
//                       onThemeChanged: onThemeChanged,
//                       isDarkMode: isDarkMode,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text("Déconnexion"),
//               onTap: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         title: const Text("Espace Étudiant"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Bonjour, $studentName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 5),
//             Text("Groupe : $groupName", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
//             const SizedBox(height: 30),
//             Expanded(
//               child: ListView(
//                 children: [
//                   HomeButton(
//                     icon: Icons.qr_code_scanner,
//                     title: "Valider ma présence",
//                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ValidatePresenceQRPage(studentId: studentId))),
//                   ),
//                   HomeButton(
//                     icon: Icons.history,
//                     title: "Mes absences",
//                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentHistoryPage(studentId: studentId))),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
