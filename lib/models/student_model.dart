class Student {
  final int id;
  final int groupId;
  final String massar;
  final String firstName;
  final String lastName;
  final String? email;

  Student({
    required this.id,
    required this.groupId,
    required this.massar,
    required this.firstName,
    required this.lastName,
    this.email,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      groupId: map['groupId'],
      massar: map['massar'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
    );
  }
}
