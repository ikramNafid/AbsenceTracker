class Session {
  int? id;
  int moduleId;
  int groupId;
  String date; // YYYY-MM-DD
  String time; // HH:MM
  String type; // cours / TP / TD

  Session({
    this.id,
    required this.moduleId,
    required this.groupId,
    required this.date,
    required this.time,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moduleId': moduleId,
      'groupId': groupId,
      'date': date,
      'time': time,
      'type': type,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      moduleId: map['moduleId'],
      groupId: map['groupId'],
      date: map['date'],
      time: map['time'],
      type: map['type'],
    );
  }
}
