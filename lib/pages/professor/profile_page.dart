import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String professorName;
  final String email;

  const ProfilePage({
    Key? key,
    required this.professorName,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/logo.png"),
            ),
            SizedBox(height: 12),
            Text('Nom et Prenom'),
            Text('Filiere'),
            Divider(),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("email@gmail.com"),
            ),
            ListTile(leading: Icon(Icons.phone), title: Text('080890987')),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text("Berkane, maroc"),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: Text("Modifier mes informations"),
            ),
          ],
        ),
      ),
    );
  }
}
