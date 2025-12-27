class Group {
  int? id;
  String name;
  int? filiereId;

  Group({this.id, required this.name, this.filiereId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'filiereId': filiereId,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      filiereId: map['filiereId'],
    );
  }
}
