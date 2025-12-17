class Group{
  final int? id;
  final String name;
  final String filiere;

  Group({this.id, required this.name , required this.filiere,});

  // covertir le group en mapbhit SQlite travaille avec map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'filiere': filiere,
    };
  }

  // CONVERTIR map en group
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      filiere: map['filiere'],
    );
  }

}
