class Absence {
  final int id;
  final String moduleName;
  final String date;
  final String status;

  Absence({
    required this.id,
    required this.moduleName,
    required this.date,
    required this.status,
  });

  factory Absence.fromMap(Map<String, dynamic> map) {
    return Absence(
      id: map['id'],
      moduleName: map['moduleName'],
      date: map['date'],
      status: map['status'],
    );
  }
}
