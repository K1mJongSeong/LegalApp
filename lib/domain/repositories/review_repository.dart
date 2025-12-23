import '../entities/review.dart';

/// 리뷰 레포지토리 인터페이스
abstract class ReviewRepository {
  /// 전문가 리뷰 목록 가져오기
  Future<List<Review>> getExpertReviews(int expertId);

  /// 사용자 리뷰 목록 가져오기
  Future<List<Review>> getUserReviews(String userId);

  /// 리뷰 작성
  Future<Review> createReview({
    required String userId,
    required int expertId,
    required String caseId,
    required double rating,
    required String content,
  });

  /// 리뷰 삭제
  Future<void> deleteReview(String id);
}


