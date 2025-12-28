import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import "../../database/login_page.dart";
import 'profile_page.dart';

class StudentHome extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentHome({super.key, required this.studentData});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Center(child: Text('Mes absences', style: TextStyle(fontSize: 24))),
      const Center(
          child: Text('Justifier mon absence', style: TextStyle(fontSize: 24))),
      ProfilePage(studentId: widget.studentData['id']), // <-- Profil ici
    ];
  }

  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Fermer le Drawer après sélection
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.studentData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Étudiant'),
        backgroundColor: Colors.indigo,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.indigo[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.indigo),
                accountName:
                    Text("${student['firstName']} ${student['lastName']}"),
                accountEmail: Text(student['email']),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.indigo),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.indigo),
                title: const Text('Mes absences'),
                onTap: () => _onItemTapped(0),
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar, color: Colors.indigo),
                title: const Text('Justifier mon absence'),
                onTap: () => _onItemTapped(1),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.indigo),
                title: const Text('Profil'),
                onTap: () {
                  Navigator.pop(context); // Ferme le Drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfilePage(studentId: widget.studentData['id']),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Se déconnecter'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
