import '../../domain/entities/legal_case.dart';

/// 법률 사건 모델 (JSON 직렬화 포함)
class LegalCaseModel extends LegalCase {
  const LegalCaseModel({
    required super.id,
    required super.userId,
    required super.category,
    required super.urgency,
    required super.title,
    required super.description,
    super.status,
    super.assignedExpert,
    required super.createdAt,
    super.updatedAt,
  });

  factory LegalCaseModel.fromJson(Map<String, dynamic> json) {
    return LegalCaseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      urgency: json['urgency'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: CaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CaseStatus.pending,
      ),
      assignedExpert: json['assigned_expert'] != null
          ? ExpertModel.fromJson(json['assigned_expert'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'urgency': urgency,
      'title': title,
      'description': description,
      'status': status.name,
      'assigned_expert': assignedExpert != null
          ? ExpertModel.fromExpert(assignedExpert!).toJson()
          : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory LegalCaseModel.fromEntity(LegalCase legalCase) {
    return LegalCaseModel(
      id: legalCase.id,
      userId: legalCase.userId,
      category: legalCase.category,
      urgency: legalCase.urgency,
      title: legalCase.title,
      description: legalCase.description,
      status: legalCase.status,
      assignedExpert: legalCase.assignedExpert,
      createdAt: legalCase.createdAt,
      updatedAt: legalCase.updatedAt,
    );
  }
}

/// 사건 내 전문가 참조용 모델
class ExpertModel extends Expert {
  const ExpertModel({
    required super.id,
    required super.name,
    super.profileImage,
    required super.specialty,
  });

  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    return ExpertModel(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      specialty: json['specialty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'specialty': specialty,
    };
  }

  factory ExpertModel.fromExpert(Expert expert) {
    return ExpertModel(
      id: expert.id,
      name: expert.name,
      profileImage: expert.profileImage,
      specialty: expert.specialty,
    );
  }
}


