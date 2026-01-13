import 'dart:io';
import 'package:law_decode/domain/entities/expert_certification.dart';

/// 전문가 인증 Repository Interface
abstract class ExpertCertificationRepository {
  /// 서류 인증 신청
  Future<ExpertCertification> submitDocumentCertification({
    required String userId,
    required File idCardFile,
    required File licenseFile,
    String? expertAccountId,
  });

  /// 즉시 인증 신청
  Future<ExpertCertification> submitInstantCertification({
    required String userId,
    required String registrationNumber,
    required String idNumber,
    String? expertAccountId,
  });

  /// userId로 인증 신청 내역 조회
  Future<List<ExpertCertification>> getCertificationsByUserId(String userId);

  /// 인증 상태 업데이트 (관리자용 - TODO)
  Future<void> updateCertificationStatus({
    required String certificationId,
    required String status,
    String? rejectReason,
  });
}











