import 'package:flutter/foundation.dart';

class StatsProvider with ChangeNotifier {
  // Example values — replace with real computations from your DB/services.
  double get absenceRate => 12; // %
  String? get mostMissedModule => 'IA1 - Sécurité';
  List<String> get activeGroupsToday => ['GI1', 'IA1'];

  // If you later fetch data async, call notifyListeners() to refresh UI.
  // Future<void> loadStats() async { ...; notifyListeners(); }
}
