import 'package:absence_tracker/pages/student/student_home.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MaterialApp(
    home: StudentHomePage(
      studentName: "Maryam",
      groupName: "GI1",
    ),
  ));
}

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


