class Session {
  int? id;
  int? moduleId;
  String date;
  String? time;
  String? type; // cours, TD, TP

  Session({this.id, this.moduleId, required this.date, this.time, this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleId': moduleId,
      'date': date,
      'time': time,
      'type': type,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      moduleId: map['moduleId'],
      date: map['date'],
      time: map['time'],
      type: map['type'],
    );
  }
}
