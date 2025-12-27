import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../professor/prof_home.dart';
import '../coordinator/coordinator_home.dart';
import '../admin/admin_home.dart'; // Assurez-vous que ces imports existent
import 'package:absence_tracker/pages/student/student_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Appel à la base de données (méthode générique pour tous les utilisateurs)
      final user = await DatabaseHelper.instance.loginUser(email, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        // On utilise 'roleId' pour la redirection
        final int role = user['roleId'];

        switch (role) {
          case 1: // Étudiant
            // On récupère les composants du nom
            final String fName = user['firstName'] ?? '';
            final String lName = user['lastName'] ?? '';
            // On crée le nom complet pour l'affichage
            final String fullName = "$fName $lName".trim();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentHomePage(
                  studentId: user['id'],
                  studentName: fullName.isEmpty ? "Étudiant" : fullName,
                  groupName: user['groupName'] ?? "Sans Groupe",
                  isDarkMode: false, // Valeur initiale pour le thème
                  onThemeChanged: (bool val) {
                    // Cette fonction sera appelée quand vous changerez le thème dans SettingsPage
                    print("Nouveau mode sombre : $val");
                  },
                ),
              ),
            );
            break;
          case 2: // Professeur
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ProfHome(professorData: user)),
            );
            break;
          case 3: // Coordinateur
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => CoordinatorHome(coordinateurId: user['id']),
              ),
            );
            break;
          case 4: // Admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHome()),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Rôle inconnu ou accès non autorisé')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email ou mot de passe incorrect")),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'École Nationale de l\'Intelligence Artificielle et du Digital - BERKANE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 10,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.indigo,
                          child:
                              Icon(Icons.school, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Absence Tracker',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Connexion',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "© 2025 ENIAD BERKANE",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
