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

class CoordinatorHome extends StatefulWidget {
  final int coordinateurId;

  const CoordinatorHome({Key? key, required this.coordinateurId})
      : super(key: key);

  @override
  State<CoordinatorHome> createState() => _CoordinatorHomeState();
}

class _CoordinatorHomeState extends State<CoordinatorHome> {
  int studentsCount = 0;
  int professorsCount = 0;
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
      final professors = await db.getProfessorsByFiliere(filiere!['id']);
      setState(() {
        studentsCount = students.length;
        professorsCount = professors.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Espace Coordinateur"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D47A1)),
              accountName: Text(
                filiere?['nom'] ?? "Filière non assignée",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text("Coordinateur"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, size: 34, color: Color(0xFF0D47A1)),
              ),
            ),
            _drawerItem(
                context, Icons.dashboard, "Tableau de bord", this.widget),
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
              DistributeStudentsByGroupPage(
                filiereId: filiere?['id'] ?? 0,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tableau de bord",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            Text("Filière : ${filiere?['nom'] ?? "Non assignée"}"),
            const SizedBox(height: 24),
            _statCard("Étudiants", studentsCount.toString(), Icons.school,
                Colors.blue),
            _statCard("Professeurs", professorsCount.toString(), Icons.person,
                Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D47A1)),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
