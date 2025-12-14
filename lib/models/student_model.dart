class StudentModel {
  final int? id;
  final int? groupId;
  final String massar;
  final String firstName;
  final String lastName;
  final String? email;

  StudentModel({
    this.id,
    this.groupId,
    required this.massar,
    required this.firstName,
    required this.lastName,
    this.email,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as int?,
      groupId: map['groupId'] as int?,
      massar: map['massar'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'massar': massar,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  String get fullName => '$firstName $lastName';
}
