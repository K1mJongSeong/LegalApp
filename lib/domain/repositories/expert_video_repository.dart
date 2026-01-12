import 'package:law_decode/domain/entities/expert_video.dart';

/// 전문가 동영상 Repository Interface
abstract class ExpertVideoRepository {
  /// 동영상 생성
  Future<ExpertVideo> createVideo({
    required String expertAccountId,
    required String videoUrl,
    required String category,
    String? title,
    String? thumbnailUrl,
    bool isPublished = false,
  });

  /// 동영상 수정
  Future<ExpertVideo> updateVideo(ExpertVideo video);

  /// 동영상 삭제
  Future<void> deleteVideo(String videoId);

  /// 동영상 ID로 조회
  Future<ExpertVideo?> getVideoById(String videoId);

  /// 전문가 계정 ID로 동영상 목록 조회
  Future<List<ExpertVideo>> getVideosByExpertAccountId(String expertAccountId);

  /// 발행된 동영상 목록 조회 (공개)
  Future<List<ExpertVideo>> getPublishedVideos({
    String? category,
    int limit = 20,
  });
}


