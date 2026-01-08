import 'package:equatable/equatable.dart';

/// 전문가 인증 신청 엔티티
class ExpertCertification extends Equatable {
  final String id; // certification document id
  final String userId; // Firebase Auth uid
  final String? expertAccountId; // expert_accounts 참조
  final String type; // document, instant
  final String? idCardUrl; // 신분증 이미지 URL
  final String? licenseUrl; // 자격증 이미지 URL
  final String? registrationNumber; // 전문가 등록 번호 (즉시 인증)
  final String? idNumber; // 신분증 발급 번호 (즉시 인증)
  final String status; // pending, approved, rejected
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectReason;

  const ExpertCertification({
    required this.id,
    required this.userId,
    this.expertAccountId,
    required this.type,
    this.idCardUrl,
    this.licenseUrl,
    this.registrationNumber,
    this.idNumber,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectReason,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        expertAccountId,
        type,
        idCardUrl,
        licenseUrl,
        registrationNumber,
        idNumber,
        status,
        submittedAt,
        reviewedAt,
        rejectReason,
      ];

  ExpertCertification copyWith({
    String? id,
    String? userId,
    String? expertAccountId,
    String? type,
    String? idCardUrl,
    String? licenseUrl,
    String? registrationNumber,
    String? idNumber,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? rejectReason,
  }) {
    return ExpertCertification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expertAccountId: expertAccountId ?? this.expertAccountId,
      type: type ?? this.type,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      idNumber: idNumber ?? this.idNumber,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }
}






