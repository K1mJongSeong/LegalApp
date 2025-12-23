import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

/// 리뷰 레포지토리 구현체 (Firebase)
class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Firestore 리뷰 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  @override
  Future<List<Review>> getExpertReviews(int expertId) async {
    try {
      final snapshot = await _reviewsCollection
          .where('expert_id', isEqualTo: expertId)
          .orderBy('created_at', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return ReviewModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      final snapshot = await _reviewsCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return ReviewModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Review> createReview({
    required String userId,
    required int expertId,
    required String caseId,
    required double rating,
    required String content,
  }) async {
    try {
      final reviewData = {
        'user_id': userId,
        'expert_id': expertId,
        'case_id': caseId,
        'rating': rating,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      };

      final docRef = await _reviewsCollection.add(reviewData);

      // 전문가 평점 업데이트
      await _updateExpertRating(expertId);

      return ReviewModel.fromJson({
        'id': docRef.id,
        ...reviewData,
      });
    } catch (e) {
      throw Exception('리뷰 작성에 실패했습니다');
    }
  }

  @override
  Future<void> deleteReview(String id) async {
    try {
      final doc = await _reviewsCollection.doc(id).get();
      if (doc.exists) {
        final expertId = doc.data()?['expert_id'] as int?;
        await _reviewsCollection.doc(id).delete();
        
        if (expertId != null) {
          await _updateExpertRating(expertId);
        }
      }
    } catch (e) {
      throw Exception('리뷰 삭제에 실패했습니다');
    }
  }

  /// 전문가 평점 업데이트
  Future<void> _updateExpertRating(int expertId) async {
    try {
      final reviews = await getExpertReviews(expertId);
      
      if (reviews.isEmpty) return;

      final avgRating = reviews.fold<double>(0, (sum, r) => sum + r.rating) / reviews.length;
      
      final expertQuery = await _firestore
          .collection('experts')
          .where('id', isEqualTo: expertId)
          .limit(1)
          .get();

      if (expertQuery.docs.isNotEmpty) {
        await expertQuery.docs.first.reference.update({
          'rating': double.parse(avgRating.toStringAsFixed(2)),
          'review_count': reviews.length,
        });
      }
    } catch (e) {
      // 평점 업데이트 실패는 무시
    }
  }
}


