import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expert_profile.dart';

/// 전문가 프로필 모델 (Firestore JSON 변환)
class ExpertProfileModel extends ExpertProfile {
  const ExpertProfileModel({
    required super.id,
    required super.userId,
    super.profileImageUrl,
    super.virtualNumber,
    super.examType,
    super.examSession,
    super.passYear,
    super.isExamPublic,
    super.createdAt,
    super.updatedAt,
  });

  /// Firestore → Model
  factory ExpertProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpertProfileModel(
      id: id,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ??
          json['profile_image_url'] as String?,
      virtualNumber: json['virtualNumber'] as String? ??
          json['virtual_number'] as String?,
      examType: json['examType'] as String? ?? json['exam_type'] as String?,
      examSession: json['examSession'] as String? ??
          json['exam_session'] as String?,
      passYear: json['passYear'] as int? ?? json['pass_year'] as int?,
      isExamPublic: json['isExamPublic'] as bool? ??
          json['is_exam_public'] as bool? ??
          true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          (json['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ??
          (json['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileImageUrl': profileImageUrl,
      'virtualNumber': virtualNumber,
      'examType': examType,
      'examSession': examSession,
      'passYear': passYear,
      'isExamPublic': isExamPublic,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Entity → Model
  factory ExpertProfileModel.fromEntity(ExpertProfile entity) {
    return ExpertProfileModel(
      id: entity.id,
      userId: entity.userId,
      profileImageUrl: entity.profileImageUrl,
      virtualNumber: entity.virtualNumber,
      examType: entity.examType,
      examSession: entity.examSession,
      passYear: entity.passYear,
      isExamPublic: entity.isExamPublic,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}



