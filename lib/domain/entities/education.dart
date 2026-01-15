/// 학력사항 엔티티
class Education {
  final String? id; // Firestore document ID (optional for new entries)
  final int? enrollmentYear; // 입학연도
  final int? graduationYear; // 졸업연도
  final String? degree; // 학위 (예: 학사, 석사, 박사)
  final String? status; // 상태 (예: 졸업, 재학, 중퇴)
  final String? schoolName; // 학교명
  final String? departmentName; // 학과명
  final bool isRepresentative; // 대표항목 여부

  const Education({
    this.id,
    this.enrollmentYear,
    this.graduationYear,
    this.degree,
    this.status,
    this.schoolName,
    this.departmentName,
    this.isRepresentative = false,
  });

  Education copyWith({
    String? id,
    int? enrollmentYear,
    int? graduationYear,
    String? degree,
    String? status,
    String? schoolName,
    String? departmentName,
    bool? isRepresentative,
  }) {
    return Education(
      id: id ?? this.id,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      graduationYear: graduationYear ?? this.graduationYear,
      degree: degree ?? this.degree,
      status: status ?? this.status,
      schoolName: schoolName ?? this.schoolName,
      departmentName: departmentName ?? this.departmentName,
      isRepresentative: isRepresentative ?? this.isRepresentative,
    );
  }
}




