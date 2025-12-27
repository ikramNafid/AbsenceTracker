class Module {
  int? id;
  String name;
  String semester;
  int groupId;

  Module(
      {this.id,
      required this.name,
      required this.semester,
      required this.groupId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'semester': semester,
      'groupId': groupId,
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'],
      name: map['name'],
      semester: map['semester'],
      groupId: map['groupId'],
    );
  }
}
