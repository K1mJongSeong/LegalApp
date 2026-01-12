/// 전문가 프로필 정보 엔티티
class ExpertProfile {
  final String id; // Firestore document ID
  final String userId; // Firebase Auth UID
  final String? profileImageUrl; // 프로필 이미지 URL
  final String? virtualNumber; // 050 가상 번호
  final String? examType; // 출신시험 (예: 변호사시험)
  final String? examSession; // 시험 회차 (예: 10회)
  final int? passYear; // 시험 합격 년도
  final bool isExamPublic; // 출신시험 공개 여부
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpertProfile({
    required this.id,
    required this.userId,
    this.profileImageUrl,
    this.virtualNumber,
    this.examType,
    this.examSession,
    this.passYear,
    this.isExamPublic = true,
    this.createdAt,
    this.updatedAt,
  });

  ExpertProfile copyWith({
    String? id,
    String? userId,
    String? profileImageUrl,
    String? virtualNumber,
    String? examType,
    String? examSession,
    int? passYear,
    bool? isExamPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpertProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      virtualNumber: virtualNumber ?? this.virtualNumber,
      examType: examType ?? this.examType,
      examSession: examSession ?? this.examSession,
      passYear: passYear ?? this.passYear,
      isExamPublic: isExamPublic ?? this.isExamPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

