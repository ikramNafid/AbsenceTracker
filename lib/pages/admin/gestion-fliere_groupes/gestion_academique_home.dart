import 'package:flutter/material.dart';
import 'filiere_page.dart';
import 'groupe_page.dart';
import 'affectation_page.dart';
import 'coordinateur_filiere_page.dart';
import "../../../database/database_helper.dart";
import 'repartition.dart';
import 'liste_etudiants_par_filieres.dart';

class GestionAcademiqueHome extends StatefulWidget {
  const GestionAcademiqueHome({super.key});

  @override
  State<GestionAcademiqueHome> createState() => _GestionAcademiqueHomeState();
}

class _GestionAcademiqueHomeState extends State<GestionAcademiqueHome> {
  int totalFilieres = 0;
  int totalGroupes = 0;
  int totalCoordinateurs = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final filieres = await DatabaseHelper.instance.getFilieres();
    final groupes = await DatabaseHelper.instance.getGroups();
    final coordinateurs = await DatabaseHelper.instance.getCoordinateurs();

    setState(() {
      totalFilieres = filieres.length;
      totalGroupes = groupes.length;
      totalCoordinateurs = coordinateurs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: const Text(
          'Gestion Académique',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 5,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[100],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF4A90E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white70,
                      child: Icon(Icons.school,
                          size: 40, color: Color(0xFF1E3A8A)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Gestion Académique',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildDrawerItem(Icons.school, 'Gestion des filières', () {
                Navigator.pop(context);
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FilierePage()))
                    .then((_) => _loadCounts());
              }),
              _buildDrawerItem(Icons.group, 'Gestion des groupes', () {
                Navigator.pop(context);
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const GroupePage()))
                    .then((_) => _loadCounts());
              }),
              _buildDrawerItem(Icons.assignment,
                  'Affectation des filières aux coordinateurs', () {
                Navigator.pop(context);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AffectationPage()))
                    .then((_) => _loadCounts());
              }),
              _buildDrawerItem(Icons.list, 'Liste des coordinateurs', () {
                Navigator.pop(context);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CoordinateurFilierePage()))
                    .then((_) => _loadCounts());
              }),
              _buildDrawerItem(
                  Icons.school, 'Répartition des étudiants par filière', () {
                Navigator.pop(context);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RepartitionPage()))
                    .then((_) => _loadCounts());
              }),
              _buildDrawerItem(Icons.group, 'Liste des étudiants par filieres',
                  () {
                Navigator.pop(context);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ListeEtudiantsParFilieres()))
                    .then((_) => _loadCounts());
              }),
              const Divider(
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey,
              ),
              _buildDrawerItem(Icons.arrow_back, 'Retour', () {
                Navigator.pop(context);
                Navigator.maybePop(context);
              }),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Bienvenue dans la gestion académique',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildDashboardCard('Filières', totalFilieres, Icons.school,
                      Colors.blueAccent, Colors.lightBlue),
                  _buildDashboardCard('Groupes', totalGroupes, Icons.group,
                      Colors.green, Colors.greenAccent),
                  _buildDashboardCard('Coordinateurs', totalCoordinateurs,
                      Icons.person, Colors.orange, Colors.deepOrangeAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: Colors.blue.withOpacity(0.2),
          child: ListTile(
            leading: Icon(icon, color: const Color(0xFF1E3A8A)),
            title: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, int count, IconData icon,
      Color startColor, Color endColor) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
