import 'package:law_decode/data/datasources/expert_video_remote_datasource.dart';
import 'package:law_decode/data/models/expert_video_model.dart';
import 'package:law_decode/domain/entities/expert_video.dart';
import 'package:law_decode/domain/repositories/expert_video_repository.dart';

/// ExpertVideo Repository 구현체
class ExpertVideoRepositoryImpl implements ExpertVideoRepository {
  final ExpertVideoRemoteDataSource _remoteDataSource;

  ExpertVideoRepositoryImpl(this._remoteDataSource);

  @override
  Future<ExpertVideo> createVideo({
    required String expertAccountId,
    required String videoUrl,
    required String category,
    String? title,
    String? thumbnailUrl,
    bool isPublished = false,
  }) async {
    return await _remoteDataSource.createVideo(
      expertAccountId: expertAccountId,
      videoUrl: videoUrl,
      category: category,
      title: title,
      thumbnailUrl: thumbnailUrl,
      isPublished: isPublished,
    );
  }

  @override
  Future<ExpertVideo> updateVideo(ExpertVideo video) async {
    final model = ExpertVideoModel.fromEntity(video);
    return await _remoteDataSource.updateVideo(model);
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    return await _remoteDataSource.deleteVideo(videoId);
  }

  @override
  Future<ExpertVideo?> getVideoById(String videoId) async {
    return await _remoteDataSource.getVideoById(videoId);
  }

  @override
  Future<List<ExpertVideo>> getVideosByExpertAccountId(
    String expertAccountId,
  ) async {
    return await _remoteDataSource.getVideosByExpertAccountId(expertAccountId);
  }

  @override
  Future<List<ExpertVideo>> getPublishedVideos({
    String? category,
    int limit = 20,
  }) async {
    return await _remoteDataSource.getPublishedVideos(
      category: category,
      limit: limit,
    );
  }
}





