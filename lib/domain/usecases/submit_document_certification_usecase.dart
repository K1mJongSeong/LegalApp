import 'dart:io';
import 'package:law_decode/domain/entities/expert_certification.dart';
import 'package:law_decode/domain/repositories/expert_certification_repository.dart';

/// 서류 인증 신청 UseCase
class SubmitDocumentCertificationUseCase {
  final ExpertCertificationRepository _repository;

  SubmitDocumentCertificationUseCase(this._repository);

  Future<ExpertCertification> call({
    required String userId,
    required File idCardFile,
    required File licenseFile,
    String? expertAccountId,
  }) async {
    // 파일 크기 검증 (8MB)
    const maxSize = 8 * 1024 * 1024; // 8MB in bytes
    if (await idCardFile.length() > maxSize) {
      throw Exception('신분증 파일 크기는 8MB를 초과할 수 없습니다.');
    }
    if (await licenseFile.length() > maxSize) {
      throw Exception('자격증 파일 크기는 8MB를 초과할 수 없습니다.');
    }

    return await _repository.submitDocumentCertification(
      userId: userId,
      idCardFile: idCardFile,
      licenseFile: licenseFile,
      expertAccountId: expertAccountId,
    );
  }
}



















