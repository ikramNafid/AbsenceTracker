import 'package:flutter/material.dart';
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

  Future<void> _loadDashboardData() async {
    if (mounted) setState(() => _isLoading = true);
    final sessions = await DatabaseHelper.instance.getSessionsToday();
    if (mounted) {
      setState(() {
        _todaySessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String profName = widget.professorData['firstName'] ?? "Professeur";

    return Scaffold(
      backgroundColor: const Color(
          0xFFF8F9FA), // Gris très clair pour faire ressortir les cartes
      appBar: AppBar(
        title: Text("Bonjour, Mr. $profName",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {}, // Optionnel : pour l'esthétique
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ProfilePage(userData: widget.professorData)),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: Colors.blue.shade700,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Séances d'aujourd'hui", Icons.event_note),
              _buildTodayCarousel(),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(thickness: 1),
              ),
              _buildSectionHeader("Menu Principal", Icons.grid_view_rounded),
              _buildMainMenuGrid(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue.shade800),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142)),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCarousel() {
    if (_isLoading) {
      return const SizedBox(
          height: 190, child: Center(child: CircularProgressIndicator()));
    }
    if (_todaySessions.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text(
              "Aucune séance prévue pour le moment.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _todaySessions.length,
        itemBuilder: (context, index) {
          final session = _todaySessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(session['time'] ?? "--:--",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text((session['type'] ?? "Cours").toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Spacer(),
            Text(
              session['moduleName'] ?? "Module Inconnu",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text("Groupe: ${session['groupName'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TakeAttendancePage(
                          sessionId: session['id'],
                          groupId: session['groupId'],
                          title: session['moduleName'],
                        )),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade800,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text("FAIRE L'APPEL",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildMenuCard(context,
            title: "Mes Modules",
            icon: Icons.collections_bookmark_rounded,
            color: Colors.orange.shade700,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ModulesPage()))),
        _buildMenuCard(context,
            title: "Calendrier",
            icon: Icons.calendar_today_rounded,
            color: Colors.green.shade600,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SessionsTodayPage()))),
        _buildMenuCard(context,
            title: "Analyses",
            icon: Icons.insights_rounded,
            color: Colors.blue.shade600,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatisticsPage()))),
        _buildMenuCard(context,
            title: "Mon Compte",
            icon: Icons.manage_accounts_rounded,
            color: Colors.purple.shade600,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ProfilePage(userData: widget.professorData)))),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142))),
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
            decoration: BoxDecoration(color: Colors.blue.shade700),
            accountName: Text(
                "${widget.professorData['firstName']} ${widget.professorData['lastName']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("${widget.professorData['email']}"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.professorData['firstName'][0],
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          _drawerItem(
              Icons.home_rounded, "Accueil", () => Navigator.pop(context)),
          _drawerItem(Icons.book_rounded, "Mes Modules", () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ModulesPage()));
          }),
          _drawerItem(Icons.calendar_month_rounded, "Mes Séances", () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SessionsTodayPage()));
          }),
          _drawerItem(Icons.bar_chart_rounded, "Statistiques", () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatisticsPage()));
          }),
          const Spacer(),
          const Divider(),
          _drawerItem(Icons.logout_rounded, "Déconnexion", () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false);
          }, color: Colors.red),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blueGrey),
      title: Text(title,
          style: TextStyle(
              color: color ?? Colors.black87,
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal)),
      onTap: onTap,
    );
  }
}
