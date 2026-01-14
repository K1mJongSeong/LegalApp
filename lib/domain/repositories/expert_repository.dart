import '../entities/expert.dart';

/// 전문가 레포지토리 인터페이스
abstract class ExpertRepository {
  /// 전문가 목록 가져오기
  Future<List<Expert>> getExperts({
    String? category,
    String? urgency,
    int page = 1,
    int limit = 10,
  });

  /// 전문가 상세 정보 가져오기
  Future<Expert> getExpertById(int id);

  /// 전문가 검색
  Future<List<Expert>> searchExperts(String query);

  /// 카테고리별 추천 전문가 가져오기
  Future<List<Expert>> getRecommendedExperts({
    required String category,
    String? urgency,
  });

  /// 인증된 전문가 목록 가져오기 (expert_accounts와 expert_profiles 조인)
  Future<List<Expert>> getVerifiedExperts({
    String? category,
  });
}


