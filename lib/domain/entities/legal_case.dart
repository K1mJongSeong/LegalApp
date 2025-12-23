/// 법률 사건 엔티티
class LegalCase {
  final String id;
  final String userId;
  final String category; // 카테고리 (labor, tax, criminal, family, real)
  final String urgency; // 긴급도 (simple, normal, urgent)
  final String title;
  final String description;
  final CaseStatus status;
  final Expert? assignedExpert;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LegalCase({
    required this.id,
    required this.userId,
    required this.category,
    required this.urgency,
    required this.title,
    required this.description,
    this.status = CaseStatus.pending,
    this.assignedExpert,
    required this.createdAt,
    this.updatedAt,
  });

  LegalCase copyWith({
    String? id,
    String? userId,
    String? category,
    String? urgency,
    String? title,
    String? description,
    CaseStatus? status,
    Expert? assignedExpert,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LegalCase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      urgency: urgency ?? this.urgency,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedExpert: assignedExpert ?? this.assignedExpert,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 법률 사건 전문가 참조용 (순환 참조 방지)
class Expert {
  final int id;
  final String name;
  final String? profileImage;
  final String specialty;

  const Expert({
    required this.id,
    required this.name,
    this.profileImage,
    required this.specialty,
  });
}

/// 사건 상태
enum CaseStatus {
  pending, // 대기 중
  inProgress, // 진행 중
  completed, // 완료
  cancelled, // 취소
}

extension CaseStatusExtension on CaseStatus {
  String get displayName {
    switch (this) {
      case CaseStatus.pending:
        return '대기 중';
      case CaseStatus.inProgress:
        return '진행 중';
      case CaseStatus.completed:
        return '완료';
      case CaseStatus.cancelled:
        return '취소';
    }
  }
}


