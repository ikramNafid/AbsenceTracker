class SessionModel {
  final int id;
  final String moduleName;
  final String date; // You can switch to DateTime if you prefer.
  final String time;

  SessionModel({
    required this.id,
    required this.moduleName,
    required this.date,
    required this.time,
  });
}
