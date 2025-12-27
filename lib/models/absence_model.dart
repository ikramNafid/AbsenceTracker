enum AbsenceStatus { present, absent, justified }

class AbsenceModel {
  final int studentId;
  AbsenceStatus status;
  String? note;

  AbsenceModel({
    required this.studentId,
    this.status = AbsenceStatus.present,
    this.note,
  });
}
