import 'package:law_decode/domain/entities/consultation_request.dart';
import 'package:law_decode/domain/repositories/consultation_request_repository.dart';

/// 상담 요청 목록 조회 UseCase
class GetConsultationRequestsUseCase {
  final ConsultationRequestRepository _repository;

  GetConsultationRequestsUseCase(this._repository);

  Future<List<ConsultationRequest>> call(String expertAccountId) async {
    return await _repository.getConsultationRequestsByExpertAccountId(
      expertAccountId,
    );
  }
}



