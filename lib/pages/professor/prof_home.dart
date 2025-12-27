import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../database/database_helper.dart';
import 'modules/modules_page.dart';
import "../../pages/professor/sessions/session_today_page.dart";
import 'statistics_page.dart';
import 'profile_page.dart';
import '../professor/take_attendance_page.dart';
import '../../database/login_page.dart';

class ProfHome extends StatefulWidget {
  final Map<String, dynamic> professorData;

  const ProfHome({super.key, required this.professorData});

  @override
  State<ProfHome> createState() => _ProfHomeState();
}

class _ProfHomeState extends State<ProfHome> {
  List<Map<String, dynamic>> _todaySessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Charger les données du tableau de bord
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final sessions = await DatabaseHelper.instance.getSessionsToday();
    setState(() {
      _todaySessions = sessions;
      _isLoading = false;
    });
  }

  // Réinitialiser la base de données (Utile pour le développement)
  Future<void> _resetDatabase(BuildContext context) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'absence_tracker.db');

    await deleteDatabase(path);
    // Forcer la réinitialisation de l'instance
    await DatabaseHelper.instance.database;

    await _loadDashboardData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "Base de données réinitialisée et données de test chargées !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String profName = widget.professorData['firstName'] ?? "Professeur";

    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour, Mr. $profName"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  "Aujourd'hui",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              _buildTodayCarousel(),
              const SizedBox(height: 20),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Text(
                  "Menu Principal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    context,
                    title: "Mes Modules",
                    icon: Icons.book,
                    color: Colors.orange,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ModulesPage())),
                  ),
                  _buildCard(
                    context,
                    title: "Mes Séances",
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SessionsTodayPage())),
                  ),
                  _buildCard(
                    context,
                    title: "Statistiques",
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StatisticsPage())),
                  ),
                  _buildCard(
                    context,
                    title: "Profil",
                    icon: Icons.person,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ProfilePage(userData: widget.professorData))),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS COMPOSANTS ---

  Widget _buildTodayCarousel() {
    if (_isLoading) {
      return const SizedBox(
          height: 160, child: Center(child: CircularProgressIndicator()));
    }
    if (_todaySessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: const Text("Aucune séance prévue pour aujourd'hui.",
            textAlign: TextAlign.center),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _todaySessions.length,
        itemBuilder: (context, index) {
          final session = _todaySessions[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(session['time'] ?? "--:--",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(session['type'] ?? "Cours",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(session['moduleName'] ?? "Module Inconnu",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    Text("Groupe: ${session['groupName'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey[600])),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TakeAttendancePage(
                                        sessionId: session['id'],
                                        groupId: session['groupId'],
                                        title: session['moduleName'],
                                      )));
                        },
                        child: const Text("Faire l'appel →"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            accountName: Text(
                "${widget.professorData['firstName']} ${widget.professorData['lastName']}"),
            accountEmail: Text("${widget.professorData['email']}"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 45, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Accueil"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text("Mes Modules"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ModulesPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Mes Séances"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SessionsTodayPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Statistiques"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StatisticsPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.redAccent),
            title: const Text("Réinitialiser les données"),
            onTap: () {
              Navigator.pop(context);
              _resetDatabase(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
