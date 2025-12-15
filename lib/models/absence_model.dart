class Absence {
  int? id;
  int sessionId;
  int studentId;
  String status; // present / absent / justified
  String? note;

  Absence({
    this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
      'note': note,
    };
  }

  factory Absence.fromMap(Map<String, dynamic> map) {
    return Absence(
      id: map['id'],
      sessionId: map['sessionId'],
      studentId: map['studentId'],
      status: map['status'],
      note: map['note'],
    );
  }
}
