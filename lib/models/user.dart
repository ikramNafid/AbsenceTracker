class User {
  int? id;
  int? groupId; // facultatif pour les rôles non étudiants
  String? massar; // facultatif pour les rôles non étudiants
  String firstName;
  String lastName;
  String email;
  String password;
  String role; // student, prof, coordinator, admin

  User({
    this.id,
    this.groupId,
    this.massar,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
  });

  // Convertir un objet User en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'massar': massar,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  // Créer un objet User à partir d’un Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      groupId: map['groupId'],
      massar: map['massar'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}
