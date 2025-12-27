class Absence {
  final int? id;
  final int studentId;
  final String studentName;
  final String groupName;
  final String moduleName;
  final String date;
  final String status; // 'Présent' ou 'Absent'

  Absence({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.groupName,
    required this.moduleName,
    required this.date,
    required this.status,
  });

  // Convertir une Absence en Map (pour insertion dans SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'groupName': groupName,
      'moduleName': moduleName,
      'date': date,
      'status': status,
    };
  }

  // Créer une Absence à partir d'un Map (lecture depuis SQLite)
  factory Absence.fromMap(Map<String, dynamic> map) {
    return Absence(
      id: map['id'] as int?,
      studentId: map['studentId'] as int,
      studentName: map['studentName'] as String,
      groupName: map['groupName'] as String,
      moduleName: map['moduleName'] as String,
      date: map['date'] as String,
      status: map['status'] as String,
    );
  }
}
