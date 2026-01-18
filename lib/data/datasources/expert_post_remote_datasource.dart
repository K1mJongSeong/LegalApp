import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/data/models/expert_post_model.dart';

/// ExpertPost Firebase DataSource
class ExpertPostRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ExpertPostRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('expert_posts');

  /// 이미지 업로드 (Firebase Storage)
  Future<String> _uploadImage(File file, String expertAccountId) async {
    try {
      debugPrint('📤 Uploading image for expert: $expertAccountId');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'expert_posts/$expertAccountId/image_$timestamp.jpg';
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      debugPrint('   → Upload success: $url');
      return url;
    } catch (e) {
      debugPrint('❌ Image upload error: $e');
      rethrow;
    }
  }

  /// 포스트 생성
  Future<ExpertPostModel> createPost({
    required String expertAccountId,
    required String postType,
    required String title,
    String? category,
    List<String>? tags,
    required String content,
    File? imageFile,
    bool isPublished = false,
  }) async {
    try {
      debugPrint('📝 PostDataSource: create($expertAccountId, $postType)');

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, expertAccountId);
      }

      final now = DateTime.now();
      final data = {
        'expertAccountId': expertAccountId,
        'postType': postType,
        'title': title,
        if (category != null) 'category': category,
        'tags': tags ?? [],
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'isPublished': isPublished,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _collection.add(data);
      debugPrint('   → 포스트 생성 완료: ${docRef.id}');

      return ExpertPostModel.fromJson({
        'id': docRef.id,
        ...data,
      });
    } catch (e) {
      debugPrint('❌ PostDataSource.create error: $e');
      rethrow;
    }
  }

  /// 포스트 수정
  Future<ExpertPostModel> updatePost(
    ExpertPostModel post, {
    File? imageFile,
  }) async {
    try {
      debugPrint('📝 PostDataSource: update(${post.id})');

      String? imageUrl = post.imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, post.expertAccountId);
      }

      final data = {
        'postType': post.postType,
        'title': post.title,
        if (post.category != null) 'category': post.category,
        'tags': post.tags,
        'content': post.content,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'isPublished': post.isPublished,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _collection.doc(post.id).update(data);
      debugPrint('   → 포스트 수정 완료');

      return ExpertPostModel.fromJson({
        'id': post.id,
        'expertAccountId': post.expertAccountId,
        ...data,
        'createdAt': Timestamp.fromDate(post.createdAt),
      });
    } catch (e) {
      debugPrint('❌ PostDataSource.update error: $e');
      rethrow;
    }
  }

  /// 포스트 삭제
  Future<void> deletePost(String postId) async {
    try {
      debugPrint('🗑️ PostDataSource: delete($postId)');
      await _collection.doc(postId).delete();
      debugPrint('   → 포스트 삭제 완료');
    } catch (e) {
      debugPrint('❌ PostDataSource.delete error: $e');
      rethrow;
    }
  }

  /// 포스트 ID로 조회
  Future<ExpertPostModel?> getPostById(String postId) async {
    try {
      debugPrint('🔍 PostDataSource: getById($postId)');
      final doc = await _collection.doc(postId).get();

      if (!doc.exists) {
        debugPrint('   → 포스트 없음');
        return null;
      }

      return ExpertPostModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('❌ PostDataSource.getById error: $e');
      rethrow;
    }
  }

  /// 전문가 계정 ID로 포스트 목록 조회
  Future<List<ExpertPostModel>> getPostsByExpertAccountId(
    String expertAccountId,
  ) async {
    try {
      debugPrint('🔍 PostDataSource: getByExpertAccountId($expertAccountId)');
      final snapshot = await _collection
          .where('expertAccountId', isEqualTo: expertAccountId)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('   → ${snapshot.docs.length}건 발견');
      return snapshot.docs.map((doc) {
        return ExpertPostModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ PostDataSource.getByExpertAccountId error: $e');
      return [];
    }
  }

  /// 발행된 포스트 목록 조회 (공개)
  Future<List<ExpertPostModel>> getPublishedPosts({
    String? postType,
    String? category,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 PostDataSource: getPublishedPosts');
      Query<Map<String, dynamic>> query = _collection
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (postType != null) {
        query = query.where('postType', isEqualTo: postType);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      debugPrint('   → ${snapshot.docs.length}건 발견');
      return snapshot.docs.map((doc) {
        return ExpertPostModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ PostDataSource.getPublishedPosts error: $e');
      return [];
    }
  }
}









