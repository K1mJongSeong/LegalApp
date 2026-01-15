import 'dart:io';
import 'package:law_decode/domain/entities/expert_post.dart';

/// 전문가 포스트 Repository Interface
abstract class ExpertPostRepository {
  /// 포스트 생성
  Future<ExpertPost> createPost({
    required String expertAccountId,
    required String postType,
    required String title,
    String? category,
    List<String>? tags,
    required String content,
    File? imageFile,
    bool isPublished = false,
  });

  /// 포스트 수정
  Future<ExpertPost> updatePost(ExpertPost post, {File? imageFile});

  /// 포스트 삭제
  Future<void> deletePost(String postId);

  /// 포스트 ID로 조회
  Future<ExpertPost?> getPostById(String postId);

  /// 전문가 계정 ID로 포스트 목록 조회
  Future<List<ExpertPost>> getPostsByExpertAccountId(String expertAccountId);

  /// 발행된 포스트 목록 조회 (공개)
  Future<List<ExpertPost>> getPublishedPosts({
    String? postType,
    String? category,
    int limit = 20,
  });
}







