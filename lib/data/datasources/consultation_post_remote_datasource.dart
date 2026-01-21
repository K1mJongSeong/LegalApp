import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/data/models/consultation_post_model.dart';

/// ConsultationPost Firebase DataSource
class ConsultationPostRemoteDataSource {
  final FirebaseFirestore _firestore;

  ConsultationPostRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('consultation_posts');

  /// 상담 글 생성
  Future<ConsultationPostModel> createConsultationPost({
    required String userId,
    required String title,
    required String content,
    required DateTime incidentDate,
    String? category,
  }) async {
    try {
      debugPrint('📝 ConsultationPostDataSource: create');
      final now = DateTime.now();
      final data = {
        'userId': userId,
        'title': title,
        'content': content,
        'incidentDate': Timestamp.fromDate(incidentDate),
        'category': category,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'views': 0,
        'comments': 0,
      };

      final docRef = await _collection.add(data);
      debugPrint('   → 생성 완료: ${docRef.id}');

      return ConsultationPostModel.fromJson({
        'id': docRef.id,
        ...data,
      });
    } catch (e) {
      debugPrint('❌ ConsultationPostDataSource.create error: $e');
      rethrow;
    }
  }

  /// 전문가 계정 ID로 예약된 상담 글 목록 조회
  Future<List<ConsultationPostModel>> getConsultationPostsByExpertAccountId(
    String expertAccountId,
  ) async {
    try {
      debugPrint('🔍 ConsultationPostDataSource: getByExpertAccountId($expertAccountId)');
      
      // consultation_requests에서 해당 전문가의 예약된 상담 글 ID 목록 가져오기
      final requestsSnapshot = await _firestore
          .collection('consultation_requests')
          .where('expertAccountId', isEqualTo: expertAccountId)
          .where('consultationPostId', isNotEqualTo: null)
          .get();

      if (requestsSnapshot.docs.isEmpty) {
        debugPrint('   → 예약된 상담 글 없음');
        return [];
      }

      final postIds = requestsSnapshot.docs
          .map((doc) => doc.data()['consultationPostId'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();

      if (postIds.isEmpty) {
        return [];
      }

      // consultation_posts에서 해당 글들 조회
      final postsSnapshot = await _collection
          .where(FieldPath.documentId, whereIn: postIds)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('   → ${postsSnapshot.docs.length}건 발견');
      return postsSnapshot.docs.map((doc) {
        return ConsultationPostModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ ConsultationPostDataSource.getByExpertAccountId error: $e');
      return [];
    }
  }

  /// 상담 글 ID로 조회
  Future<ConsultationPostModel?> getConsultationPostById(String postId) async {
    try {
      final doc = await _collection.doc(postId).get();
      if (!doc.exists) {
        return null;
      }
      return ConsultationPostModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      debugPrint('❌ ConsultationPostDataSource.getById error: $e');
      return null;
    }
  }

  /// 사용자 ID로 최근 상담 글 조회 (예약 시 사용)
  Future<ConsultationPostModel?> getLatestConsultationPostByUserId(String userId) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return ConsultationPostModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    } catch (e) {
      debugPrint('❌ ConsultationPostDataSource.getLatestByUserId error: $e');
      return null;
    }
  }

  /// 사용자 ID로 모든 상담 글 조회
  Future<List<ConsultationPostModel>> getConsultationPostsByUserId(String userId) async {
    try {
      debugPrint('🔍 ConsultationPostDataSource: getConsultationPostsByUserId($userId)');
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('   → ${querySnapshot.docs.length}건 발견');
      return querySnapshot.docs.map((doc) {
        return ConsultationPostModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ ConsultationPostDataSource.getConsultationPostsByUserId error: $e');
      return [];
    }
  }

  /// 모든 상담 글 조회
  Future<List<ConsultationPostModel>> getAllConsultationPosts() async {
    try {
      debugPrint('🔍 ConsultationPostDataSource: getAllConsultationPosts');
      final querySnapshot = await _collection
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('   → ${querySnapshot.docs.length}건 발견');
      return querySnapshot.docs.map((doc) {
        return ConsultationPostModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ ConsultationPostDataSource.getAllConsultationPosts error: $e');
      return [];
    }
  }

  /// 상담 글 삭제
  Future<void> deleteConsultationPost(String postId) async {
    try {
      debugPrint('🗑 ConsultationPostDataSource: delete($postId)');
      await _collection.doc(postId).delete();
      debugPrint('   → 삭제 완료');
    } catch (e) {
      debugPrint('❌ ConsultationPostDataSource.delete error: $e');
      rethrow;
    }
  }
}

