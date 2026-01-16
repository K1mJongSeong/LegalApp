import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_decode/domain/entities/expert_certification.dart';

/// ExpertCertification Data Model
class ExpertCertificationModel extends ExpertCertification {
  const ExpertCertificationModel({
    required super.id,
    required super.userId,
    super.expertAccountId,
    required super.type,
    super.idCardUrl,
    super.licenseUrl,
    super.registrationNumber,
    super.idNumber,
    required super.status,
    required super.submittedAt,
    super.reviewedAt,
    super.rejectReason,
  });

  /// Firestore → Model
  factory ExpertCertificationModel.fromJson(Map<String, dynamic> json) {
    return ExpertCertificationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      expertAccountId: json['expertAccountId'] as String? ??
          json['expert_account_id'] as String?,
      type: json['type'] as String? ?? 'document',
      idCardUrl:
          json['idCardUrl'] as String? ?? json['id_card_url'] as String?,
      licenseUrl:
          json['licenseUrl'] as String? ?? json['license_url'] as String?,
      registrationNumber: json['registrationNumber'] as String? ??
          json['registration_number'] as String?,
      idNumber: json['idNumber'] as String? ?? json['id_number'] as String?,
      status: json['status'] as String? ?? 'pending',
      submittedAt: (json['submittedAt'] as Timestamp?)?.toDate() ??
          (json['submitted_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      reviewedAt: (json['reviewedAt'] as Timestamp?)?.toDate() ??
          (json['reviewed_at'] as Timestamp?)?.toDate(),
      rejectReason: json['rejectReason'] as String? ??
          json['reject_reason'] as String?,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'expertAccountId': expertAccountId,
      'type': type,
      'idCardUrl': idCardUrl,
      'licenseUrl': licenseUrl,
      'registrationNumber': registrationNumber,
      'idNumber': idNumber,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'rejectReason': rejectReason,
    };
  }

  /// Entity → Model
  factory ExpertCertificationModel.fromEntity(ExpertCertification entity) {
    return ExpertCertificationModel(
      id: entity.id,
      userId: entity.userId,
      expertAccountId: entity.expertAccountId,
      type: entity.type,
      idCardUrl: entity.idCardUrl,
      licenseUrl: entity.licenseUrl,
      registrationNumber: entity.registrationNumber,
      idNumber: entity.idNumber,
      status: entity.status,
      submittedAt: entity.submittedAt,
      reviewedAt: entity.reviewedAt,
      rejectReason: entity.rejectReason,
    );
  }
}















