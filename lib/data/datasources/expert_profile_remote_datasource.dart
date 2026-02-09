import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expert_profile.dart';
import '../models/expert_profile_model.dart';

/// 전문가 프로필 원격 데이터 소스 (Firestore)
class ExpertProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'expert_profiles';

  ExpertProfileRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// userId로 프로필 조회
  Future<ExpertProfile?> getProfileByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return ExpertProfileModel.fromJson(doc.data(), doc.id);
    } catch (e) {
      throw Exception('프로필 조회 실패: $e');
    }
  }

  /// 프로필 저장/업데이트
  Future<void> saveProfile(ExpertProfile profile) async {
    try {
      final model = ExpertProfileModel.fromEntity(profile);
      final json = model.toJson();
      
      // updatedAt 자동 업데이트
      json['updatedAt'] = Timestamp.now();

      // userId로 기존 문서 찾기
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: profile.userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // 새로 생성
        json['createdAt'] = Timestamp.now();
        await _firestore.collection(_collection).add(json);
      } else {
        // 업데이트
        final docId = querySnapshot.docs.first.id;
        await _firestore.collection(_collection).doc(docId).update(json);
      }
    } catch (e) {
      throw Exception('프로필 저장 실패: $e');
    }
  }

  /// 프로필 이미지 URL 업데이트
  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('프로필을 찾을 수 없습니다.');
      }

      final docId = querySnapshot.docs.first.id;
      await _firestore.collection(_collection).doc(docId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('프로필 이미지 업데이트 실패: $e');
    }
  }
}


















