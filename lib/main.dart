// import 'package:absence_tracker/pages/student/student_home.dart';
// import 'package:flutter/material.dart';


// void main() {
//   runApp(MaterialApp(
//     home: StudentHomePage(
//       studentName: "Maryam",
//       groupName: "GI1",
//     ),
//   ));
// }

// import 'package:flutter/material.dart';

// import 'database/login_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LoginPage(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'pages/student/student_home.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: 
//       // StudentHomePage(
//       //   studentId: loggedStudent.id,
//       //   studentName: loggedStudent.name,
//       //   groupName: loggedStudent.group,),
//       StudentHomePage(
//         studentId: 1,
//         studentName: "Maryam",
//         groupName: "GI-1",
//       ),
    
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'pages/student/student_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Variable d'état pour le mode sombre
  ThemeMode _themeMode = ThemeMode.light;

  // Fonction pour basculer le thème
  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absence Tracker',
      
      // Configuration des thèmes
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: _themeMode, // Utilisation de la variable d'état

      home: StudentHomePage(
        studentId: 1,
        studentName: "Maryam",
        groupName: "GI-1",
        onThemeChanged: toggleTheme, // On passe la fonction aux pages
        isDarkMode: _themeMode == ThemeMode.dark, // On passe l'état actuel
      ),
    );
  }
}


