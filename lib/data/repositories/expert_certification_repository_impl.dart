import 'dart:io';
import 'package:law_decode/data/datasources/expert_certification_remote_datasource.dart';
import 'package:law_decode/domain/entities/expert_certification.dart';
import 'package:law_decode/domain/repositories/expert_certification_repository.dart';

/// ExpertCertification Repository 구현체
class ExpertCertificationRepositoryImpl
    implements ExpertCertificationRepository {
  final ExpertCertificationRemoteDataSource _remoteDataSource;

  ExpertCertificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<ExpertCertification> submitDocumentCertification({
    required String userId,
    required File idCardFile,
    required File licenseFile,
    String? expertAccountId,
  }) async {
    return await _remoteDataSource.submitDocumentCertification(
      userId: userId,
      idCardFile: idCardFile,
      licenseFile: licenseFile,
      expertAccountId: expertAccountId,
    );
  }

  @override
  Future<ExpertCertification> submitInstantCertification({
    required String userId,
    required String registrationNumber,
    required String idNumber,
    String? expertAccountId,
  }) async {
    return await _remoteDataSource.submitInstantCertification(
      userId: userId,
      registrationNumber: registrationNumber,
      idNumber: idNumber,
      expertAccountId: expertAccountId,
    );
  }

  @override
  Future<List<ExpertCertification>> getCertificationsByUserId(
    String userId,
  ) async {
    return await _remoteDataSource.getCertificationsByUserId(userId);
  }

  @override
  Future<void> updateCertificationStatus({
    required String certificationId,
    required String status,
    String? rejectReason,
  }) async {
    return await _remoteDataSource.updateCertificationStatus(
      certificationId: certificationId,
      status: status,
      rejectReason: rejectReason,
    );
  }
}


















