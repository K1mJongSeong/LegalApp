import 'package:law_decode/data/datasources/consultation_post_remote_datasource.dart';
import 'package:law_decode/domain/entities/consultation_post.dart';
import 'package:law_decode/domain/repositories/consultation_post_repository.dart';

/// ConsultationPost Repository 구현체
class ConsultationPostRepositoryImpl implements ConsultationPostRepository {
  final ConsultationPostRemoteDataSource _remoteDataSource;

  ConsultationPostRepositoryImpl(this._remoteDataSource);

  @override
  Future<ConsultationPost> createConsultationPost({
    required String userId,
    required String title,
    required String content,
    required DateTime incidentDate,
    String? category,
  }) async {
    return await _remoteDataSource.createConsultationPost(
      userId: userId,
      title: title,
      content: content,
      incidentDate: incidentDate,
      category: category,
    );
  }

  @override
  Future<List<ConsultationPost>> getConsultationPostsByExpertAccountId(
    String expertAccountId,
  ) async {
    return await _remoteDataSource.getConsultationPostsByExpertAccountId(
      expertAccountId,
    );
  }

  @override
  Future<ConsultationPost?> getConsultationPostById(String postId) async {
    return await _remoteDataSource.getConsultationPostById(postId);
  }

  @override
  Future<ConsultationPost?> getLatestConsultationPostByUserId(String userId) async {
    return await _remoteDataSource.getLatestConsultationPostByUserId(userId);
  }
}

