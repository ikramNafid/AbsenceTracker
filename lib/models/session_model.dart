class SessionModel {
  int? id;
  String name;
  String groupName;

  SessionModel({this.id, required this.name, required this.groupName});

  // Convertir un Map (SQLite) en SessionModel
  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'],
      name: map['name'],
      groupName: map['group_name'],
    );
  }

  // Convertir un SessionModel en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'group_name': groupName,
    };
  }
}
