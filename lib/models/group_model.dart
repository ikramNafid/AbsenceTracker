class GroupModel {
  final int? id;
  final String name;
  final String? filiere;

  GroupModel({this.id, required this.name, this.filiere});

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      filiere: map['filiere'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'filiere': filiere};
  }
}
