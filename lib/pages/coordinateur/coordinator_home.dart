import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'absence_rate_page.dart';
import 'alert_absence_page.dart';
import 'affect_prof_page.dart';
import 'assigned_students_page.dart';
import 'distribute_students_by_group_page.dart';
import 'distribute_modules_by_group_page.dart';
import 'module_list_with_groups_page.dart';
import 'liste_module_froupe.dart';
import 'ProfesseursAssignesPage.dart';
import "../../database/login_page.dart";

class CoordinatorHome extends StatefulWidget {
  final int coordinateurId;

  const CoordinatorHome({Key? key, required this.coordinateurId})
      : super(key: key);

  @override
  State<CoordinatorHome> createState() => _CoordinatorHomeState();
}

class _CoordinatorHomeState extends State<CoordinatorHome> {
  int studentsCount = 0;
  Map<String, dynamic>? filiere;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final db = DatabaseHelper.instance;
    filiere = await db.getFiliereByCoordinateur(widget.coordinateurId);

    if (filiere != null) {
      final students = await db.getStudentsByFiliere(filiere!['id']);
      setState(() {
        studentsCount = students.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FF),
      appBar: AppBar(
        title: const Text("Espace Coordinateur"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 4,
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 30),
            _buildStudentsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue, Coordinateur !",
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Filière : ${filiere?['nom'] ?? "Non assignée"}",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.blue.shade100,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue.withOpacity(0.15),
              child: Icon(Icons.school, color: Colors.blue.shade700, size: 36),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nombre d'étudiants",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800),
                ),
                const SizedBox(height: 8),
                Text(
                  studentsCount.toString(),
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              filiere?['nom'] ?? "Filière non assignée",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("Coordinateur"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.school, size: 34, color: Color(0xFF1E3A8A)),
            ),
          ),
          _drawerItem(context, Icons.dashboard, "Tableau de bord", this.widget),
          _drawerItem(
            context,
            Icons.list,
            "Gestion des modéles de IRSI",
            ModuleListWithGroupsPage(filiereId: filiere?['id'] ?? 0),
          ),
          _drawerItem(
            context,
            Icons.list,
            "Liste des modéles avec groupes",
            const ListeModuleGroupe(),
          ),
          _drawerItem(
            context,
            Icons.list,
            "Répartition des modéles par groupe",
            DistributeModulesByGroupPage(filiereId: filiere?['id'] ?? 0),
          ),
          _drawerItem(
            context,
            Icons.bar_chart,
            "Taux d'absences",
            const AbsenceRatePage(),
          ),
          _drawerItem(
            context,
            Icons.warning_amber,
            "Alertes absences",
            const AlertAbsencePage(),
          ),
          _drawerItem(
            context,
            Icons.people,
            "Affectation professeurs",
            const AffectProfPage(),
          ),
          _drawerItem(
            context,
            Icons.list,
            "Liste des professeurs avec modules assignés",
            const ProfesseursAssignesPage(),
          ),
          _drawerItem(
            context,
            Icons.school,
            "Étudiants assignés",
            AssignedStudentsPage(filiereId: filiere?['id'] ?? 0),
          ),
          _drawerItem(
            context,
            Icons.group,
            "Répartition des étudiants par groupe",
            DistributeStudentsByGroupPage(filiereId: filiere?['id'] ?? 0),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A8A)),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
