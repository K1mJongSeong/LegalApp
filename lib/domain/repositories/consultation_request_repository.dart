import 'package:law_decode/domain/entities/consultation_request.dart';

/// 상담 요청 Repository Interface (전문가 대시보드용)
abstract class ConsultationRequestRepository {
  /// 전문가 계정 ID로 상담 요청 목록 조회
  Future<List<ConsultationRequest>> getConsultationRequestsByExpertAccountId(
    String expertAccountId,
  );

  /// 상담 요청 상태 업데이트
  Future<void> updateConsultationStatus({
    required String requestId,
    required String status,
  });
}



