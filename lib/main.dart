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