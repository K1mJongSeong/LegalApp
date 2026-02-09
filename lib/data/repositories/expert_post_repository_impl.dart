import 'dart:io';
import 'package:law_decode/data/datasources/expert_post_remote_datasource.dart';
import 'package:law_decode/data/models/expert_post_model.dart';
import 'package:law_decode/domain/entities/expert_post.dart';
import 'package:law_decode/domain/repositories/expert_post_repository.dart';

/// ExpertPost Repository 구현체
class ExpertPostRepositoryImpl implements ExpertPostRepository {
  final ExpertPostRemoteDataSource _remoteDataSource;

  ExpertPostRepositoryImpl(this._remoteDataSource);

  @override
  Future<ExpertPost> createPost({
    required String expertAccountId,
    required String postType,
    required String title,
    String? category,
    List<String>? tags,
    required String content,
    File? imageFile,
    bool isPublished = false,
  }) async {
    return await _remoteDataSource.createPost(
      expertAccountId: expertAccountId,
      postType: postType,
      title: title,
      category: category,
      tags: tags,
      content: content,
      imageFile: imageFile,
      isPublished: isPublished,
    );
  }

  @override
  Future<ExpertPost> updatePost(ExpertPost post, {File? imageFile}) async {
    final model = ExpertPostModel.fromEntity(post);
    return await _remoteDataSource.updatePost(model, imageFile: imageFile);
  }

  @override
  Future<void> deletePost(String postId) async {
    return await _remoteDataSource.deletePost(postId);
  }

  @override
  Future<ExpertPost?> getPostById(String postId) async {
    return await _remoteDataSource.getPostById(postId);
  }

  @override
  Future<List<ExpertPost>> getPostsByExpertAccountId(
    String expertAccountId,
  ) async {
    return await _remoteDataSource.getPostsByExpertAccountId(expertAccountId);
  }

  @override
  Future<List<ExpertPost>> getPublishedPosts({
    String? postType,
    String? category,
    int limit = 20,
  }) async {
    return await _remoteDataSource.getPublishedPosts(
      postType: postType,
      category: category,
      limit: limit,
    );
  }
}



















