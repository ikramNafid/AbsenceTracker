import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/stats_provider.dart';
import 'providers/session_provider.dart';
import 'screens/home_screen.dart';
// import other screens...

void main() {
  runApp(const AbsenceTrackerApp());
}

class AbsenceTrackerApp extends StatelessWidget {
  const AbsenceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        // Add other providers here...
      ],
      child: MaterialApp(
        title: 'Absence Tracker',
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/groups': (context) =>
              const Placeholder(), // replace with GroupsScreen()
          '/sessions': (context) =>
              const Placeholder(), // replace with SessionsScreen()
          '/markAbsence': (context) =>
              const Placeholder(), // replace with MarkAbsenceScreen()
          '/statistics': (context) =>
              const Placeholder(), // replace with StatisticsScreen()
          '/settings': (context) =>
              const Placeholder(), // replace with SettingsScreen()
        },
      ),
    );
  }
}
