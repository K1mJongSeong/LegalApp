import 'package:law_decode/domain/entities/consultation_post.dart';

/// 상담 글 Repository Interface
abstract class ConsultationPostRepository {
  /// 상담 글 생성
  Future<ConsultationPost> createConsultationPost({
    required String userId,
    required String title,
    required String content,
    required DateTime incidentDate,
    String? category,
  });

  /// 전문가 계정 ID로 예약된 상담 글 목록 조회
  Future<List<ConsultationPost>> getConsultationPostsByExpertAccountId(
    String expertAccountId,
  );

  /// 상담 글 ID로 조회
  Future<ConsultationPost?> getConsultationPostById(String postId);

  /// 사용자 ID로 최근 상담 글 조회 (예약 시 사용)
  Future<ConsultationPost?> getLatestConsultationPostByUserId(String userId);

  /// 사용자 ID로 상담 글 목록 조회
  Future<List<ConsultationPost>> getConsultationPostsByUserId(String userId);

  /// 모든 상담 글 목록 조회
  Future<List<ConsultationPost>> getAllConsultationPosts();

  /// 상담 글 삭제
  Future<void> deleteConsultationPost(String postId);
}