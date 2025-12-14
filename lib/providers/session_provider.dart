import 'package:flutter/foundation.dart';
import '../models/session_model.dart';

class SessionProvider with ChangeNotifier {
  // Stub data — replace with DB results.
  List<SessionModel> getUpcomingSessions() {
    return [
      SessionModel(
        id: 1,
        moduleName: 'Module 1',
        date: '10/11/2022',
        time: '10h00',
      ),
      SessionModel(
        id: 2,
        moduleName: 'Module 1',
        date: '10/11/2022',
        time: '12h00',
      ),
    ];
  }

  // Future<void> loadUpcoming() async { ...; notifyListeners(); }
}
