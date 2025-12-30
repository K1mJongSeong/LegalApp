import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/expert.dart';
import '../../domain/repositories/expert_repository.dart';
import '../models/expert_model.dart';

/// 전문가 레포지토리 구현체 (Firebase)
class ExpertRepositoryImpl implements ExpertRepository {
  final FirebaseFirestore _firestore;

  ExpertRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Firestore 전문가 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _expertsCollection =>
      _firestore.collection('experts');

  @override
  Future<List<Expert>> getExperts({
    String? category,
    String? urgency,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint('🔍 ExpertRepository.getExperts() called');
      debugPrint('   category filter: $category');
      
      Query<Map<String, dynamic>> query = _expertsCollection
          .where('is_available', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        debugPrint('   Applying category filter: $category');
        query = query.where('categories', arrayContains: category);
      }
      
      // rating 정렬은 인덱스가 없을 수 있으므로 클라이언트에서 정렬
      final snapshot = await query.limit(limit).get();
      
      debugPrint('   Found ${snapshot.docs.length} experts');

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final experts = snapshot.docs.map((doc) {
        return ExpertModel.fromJson({
          'id': int.tryParse(doc.id) ?? doc.id.hashCode,
          ...doc.data(),
        });
      }).toList();
      
      // 클라이언트에서 rating 정렬
      experts.sort((a, b) => b.rating.compareTo(a.rating));
      
      return experts;
    } catch (e) {
      // Firestore 인덱스 오류 등의 경우 빈 목록 반환
      debugPrint('❌ ExpertRepository error: $e');
      return [];
    }
  }

  @override
  Future<Expert> getExpertById(int id) async {
    try {
      final snapshot = await _expertsCollection
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('전문가를 찾을 수 없습니다');
      }

      final doc = snapshot.docs.first;
      return ExpertModel.fromJson({
        'id': id,
        ...doc.data(),
      });
    } catch (e) {
      throw Exception('전문가 정보를 불러오는데 실패했습니다');
    }
  }

  @override
  Future<List<Expert>> searchExperts(String query) async {
    try {
      // Firestore는 full-text search를 지원하지 않으므로
      // 이름으로만 검색 (실제 구현 시 Algolia 등 사용 권장)
      final snapshot = await _expertsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return ExpertModel.fromJson({
          'id': doc.id.hashCode,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Expert>> getRecommendedExperts({
    required String category,
    String? urgency,
  }) async {
    try {
      final snapshot = await _expertsCollection
          .where('categories', arrayContains: category)
          .where('is_available', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(5)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return ExpertModel.fromJson({
          'id': doc.id.hashCode,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
