import 'package:flutter/material.dart';
import '../../database/models/user.dart';
import '../../database/tables/user_table.dart';
import '../professor/prof_home.dart';
// import '../student/student_home.dart';
// import '../coordinator/coordinator_home.dart';
// import '../admin/admin_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    User? user = await UserTable.getUserByEmail(email);

    // Valeur par défaut pour éviter l'erreur
    Widget nextPage = const LoginPage();

    if (user != null && user.password == password) {
      // Redirection selon le rôle
      switch (user.role) {
        case 'student':
          // nextPage = const StudentHome();
          break;
        case 'prof':
          nextPage = const ProfHome(); // page active pour l'instant
          break;
        case 'coordinator':
          // nextPage = const CoordinatorHome();
          break;
        case 'admin':
          // nextPage = const AdminHome();
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou mot de passe incorrect')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty
                    ? 'Veuillez saisir votre email'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty
                    ? 'Veuillez saisir votre mot de passe'
                    : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Se connecter'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
