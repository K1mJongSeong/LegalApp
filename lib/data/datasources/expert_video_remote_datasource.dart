import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/data/models/expert_video_model.dart';

/// ExpertVideo Firebase DataSource
class ExpertVideoRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpertVideoRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('expert_videos');

  /// 동영상 생성
  Future<ExpertVideoModel> createVideo({
    required String expertAccountId,
    required String videoUrl,
    required String category,
    String? title,
    String? thumbnailUrl,
    bool isPublished = false,
  }) async {
    try {
      debugPrint('📝 VideoDataSource: create($expertAccountId, $category)');

      final now = DateTime.now();
      final data = {
        'expertAccountId': expertAccountId,
        'videoUrl': videoUrl,
        'category': category,
        if (title != null) 'title': title,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'isPublished': isPublished,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _collection.add(data);
      debugPrint('   → 동영상 생성 완료: ${docRef.id}');

      return ExpertVideoModel.fromJson({
        'id': docRef.id,
        ...data,
      });
    } catch (e) {
      debugPrint('❌ VideoDataSource.create error: $e');
      rethrow;
    }
  }

  /// 동영상 수정
  Future<ExpertVideoModel> updateVideo(ExpertVideoModel video) async {
    try {
      debugPrint('📝 VideoDataSource: update(${video.id})');

      final data = {
        'videoUrl': video.videoUrl,
        'category': video.category,
        if (video.title != null) 'title': video.title,
        if (video.thumbnailUrl != null) 'thumbnailUrl': video.thumbnailUrl,
        'isPublished': video.isPublished,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _collection.doc(video.id).update(data);
      debugPrint('   → 동영상 수정 완료');

      return ExpertVideoModel.fromJson({
        'id': video.id,
        'expertAccountId': video.expertAccountId,
        ...data,
        'createdAt': Timestamp.fromDate(video.createdAt),
      });
    } catch (e) {
      debugPrint('❌ VideoDataSource.update error: $e');
      rethrow;
    }
  }

  /// 동영상 삭제
  Future<void> deleteVideo(String videoId) async {
    try {
      debugPrint('🗑️ VideoDataSource: delete($videoId)');
      await _collection.doc(videoId).delete();
      debugPrint('   → 동영상 삭제 완료');
    } catch (e) {
      debugPrint('❌ VideoDataSource.delete error: $e');
      rethrow;
    }
  }

  /// 동영상 ID로 조회
  Future<ExpertVideoModel?> getVideoById(String videoId) async {
    try {
      debugPrint('🔍 VideoDataSource: getById($videoId)');
      final doc = await _collection.doc(videoId).get();

      if (!doc.exists) {
        debugPrint('   → 동영상 없음');
        return null;
      }

      return ExpertVideoModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('❌ VideoDataSource.getById error: $e');
      rethrow;
    }
  }

  /// 전문가 계정 ID로 동영상 목록 조회
  Future<List<ExpertVideoModel>> getVideosByExpertAccountId(
    String expertAccountId,
  ) async {
    try {
      debugPrint('🔍 VideoDataSource: getByExpertAccountId($expertAccountId)');
      final snapshot = await _collection
          .where('expertAccountId', isEqualTo: expertAccountId)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('   → ${snapshot.docs.length}건 발견');
      return snapshot.docs.map((doc) {
        return ExpertVideoModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ VideoDataSource.getByExpertAccountId error: $e');
      return [];
    }
  }

  /// 발행된 동영상 목록 조회 (공개)
  Future<List<ExpertVideoModel>> getPublishedVideos({
    String? category,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 VideoDataSource: getPublishedVideos');
      Query<Map<String, dynamic>> query = _collection
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      debugPrint('   → ${snapshot.docs.length}건 발견');
      return snapshot.docs.map((doc) {
        return ExpertVideoModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ VideoDataSource.getPublishedVideos error: $e');
      return [];
    }
  }
}




















