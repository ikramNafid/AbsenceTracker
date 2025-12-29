import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../database/database_helper.dart';
import 'modules/modules_page.dart';
import 'sessions/sessions_today_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';
import '../professor/take_attendance_page.dart';
import '../auth/login_page.dart';

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

  // Charger les données des séances du jour
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final sessions = await DatabaseHelper.instance.getSessionsToday();
    setState(() {
      _todaySessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String profName = widget.professorData['firstName'] ?? "Professeur";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Bonjour, Mr. $profName"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: "Mon Profil",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(userData: widget.professorData),
              ),
            ),
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
                padding: EdgeInsets.fromLTRB(20, 25, 16, 12),
                child: Text(
                  "Séances d'aujourd'hui",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              _buildTodayCarousel(),
              const SizedBox(height: 10),
              const Divider(indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 16, 16),
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
                  _buildMenuCard(
                    context,
                    title: "Mes Modules",
                    icon: Icons.book,
                    color: Colors.orange,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ModulesPage())),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Mes Séances",
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SessionsTodayPage())),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Statistiques",
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StatisticsPage())),
                  ),
                  _buildMenuCard(
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

  // --- NOUVEAU DESIGN DES CARTES DE SÉANCES ---
  Widget _buildTodayCarousel() {
    if (_isLoading) {
      return const SizedBox(
          height: 180, child: Center(child: CircularProgressIndicator()));
    }
    if (_todaySessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!)),
        child: const Text(
          "Aucune séance prévue pour aujourd'hui.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        itemCount: _todaySessions.length,
        itemBuilder: (context, index) {
          final session = _todaySessions[index];
          return Container(
            width: 290,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            session['time'] ?? "--:--",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          (session['type'] ?? "Cours").toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    session['moduleName'] ?? "Module Inconnu",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Groupe: ${session['groupName'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TakeAttendancePage(
                              sessionId: session['id'],
                              groupId: session['groupId'],
                              title: session['moduleName'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "FAIRE L'APPEL",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget pour les cartes du menu principal
  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // --- DRAWER NETTOYÉ ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade700),
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
