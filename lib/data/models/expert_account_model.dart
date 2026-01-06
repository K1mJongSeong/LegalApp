import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_decode/domain/entities/expert_account.dart';

/// ExpertAccount Data Model
class ExpertAccountModel extends ExpertAccount {
  const ExpertAccountModel({
    required super.id,
    required super.userId,
    super.expertPublicId,
    required super.isVerified,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Firestore → Model
  factory ExpertAccountModel.fromJson(Map<String, dynamic> json) {
    return ExpertAccountModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      expertPublicId: json['expertPublicId'] as String? ??
          json['expert_public_id'] as String?,
      isVerified: json['isVerified'] as bool? ??
          json['is_verified'] as bool? ??
          false,
      status: json['status'] as String? ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          (json['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ??
          (json['updated_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'expertPublicId': expertPublicId,
      'isVerified': isVerified,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Entity → Model
  factory ExpertAccountModel.fromEntity(ExpertAccount entity) {
    return ExpertAccountModel(
      id: entity.id,
      userId: entity.userId,
      expertPublicId: entity.expertPublicId,
      isVerified: entity.isVerified,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}


