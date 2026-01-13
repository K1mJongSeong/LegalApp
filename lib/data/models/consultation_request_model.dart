import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_decode/domain/entities/consultation_request.dart';

/// ConsultationRequest Data Model
class ConsultationRequestModel extends ConsultationRequest {
  const ConsultationRequestModel({
    required super.id,
    required super.expertAccountId,
    super.expertPublicId,
    required super.userId,
    required super.title,
    required super.status,
    super.scheduledAt,
    required super.createdAt,
  });

  /// Firestore → Model
  factory ConsultationRequestModel.fromJson(Map<String, dynamic> json) {
    return ConsultationRequestModel(
      id: json['id'] as String? ?? '',
      expertAccountId: json['expertAccountId'] as String? ??
          json['expert_account_id'] as String? ??
          '',
      expertPublicId: json['expertPublicId'] as String? ??
          json['expert_public_id'] as String?,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'waiting',
      scheduledAt: (json['scheduledAt'] as Timestamp?)?.toDate() ??
          (json['scheduled_at'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          (json['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'expertAccountId': expertAccountId,
      'expertPublicId': expertPublicId,
      'userId': userId,
      'title': title,
      'status': status,
      'scheduledAt':
          scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}











