import 'package:law_decode/domain/entities/expert_certification.dart';
import 'package:law_decode/domain/repositories/expert_certification_repository.dart';

/// 즉시 인증 신청 UseCase
class SubmitInstantCertificationUseCase {
  final ExpertCertificationRepository _repository;

  SubmitInstantCertificationUseCase(this._repository);

  Future<ExpertCertification> call({
    required String userId,
    required String registrationNumber,
    required String idNumber,
    String? expertAccountId,
  }) async {
    // 입력 검증
    if (registrationNumber.trim().isEmpty) {
      throw Exception('전문가 등록 번호를 입력해주세요.');
    }
    if (idNumber.trim().isEmpty) {
      throw Exception('신분증 발급 번호를 입력해주세요.');
    }

    return await _repository.submitInstantCertification(
      userId: userId,
      registrationNumber: registrationNumber.trim(),
      idNumber: idNumber.trim(),
      expertAccountId: expertAccountId,
    );
  }
}







