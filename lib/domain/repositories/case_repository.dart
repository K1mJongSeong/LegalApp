import '../entities/legal_case.dart';

/// 사건 레포지토리 인터페이스
abstract class CaseRepository {
  /// 사용자의 사건 목록 가져오기
  Future<List<LegalCase>> getUserCases(String userId);

  /// 사건 상세 정보 가져오기
  Future<LegalCase> getCaseById(String id);

  /// 새 사건 생성
  Future<LegalCase> createCase({
    required String userId,
    required String category,
    required String urgency,
    required String title,
    required String description,
  });

  /// 사건 업데이트
  Future<LegalCase> updateCase(LegalCase legalCase);

  /// 사건 삭제
  Future<void> deleteCase(String id);

  /// 전문가 배정
  Future<LegalCase> assignExpert({
    required String caseId,
    required int expertId,
  });
}


