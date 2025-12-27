class Filiere {
  int? id;
  String name;
  String? code;
  String? description;

  Filiere({this.id, required this.name, this.code, this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
    };
  }

  factory Filiere.fromMap(Map<String, dynamic> map) {
    return Filiere(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      description: map['description'],
    );
  }
}
