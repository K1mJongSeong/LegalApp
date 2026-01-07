import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/data/models/expert_account_model.dart';

/// ExpertAccount Firebase DataSource
class ExpertAccountRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpertAccountRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('expert_accounts');

  /// userId로 전문가 계정 조회
  Future<ExpertAccountModel?> getExpertAccountByUserId(String userId) async {
    try {
      debugPrint('🔍 ExpertAccountDataSource: getByUserId($userId)');
      final snapshot =
          await _collection.where('userId', isEqualTo: userId).limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint('   → 계정 없음');
        return null;
      }

      final doc = snapshot.docs.first;
      debugPrint('   → 계정 발견: ${doc.id}');
      return ExpertAccountModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    } catch (e) {
      debugPrint('❌ ExpertAccountDataSource.getByUserId error: $e');
      rethrow;
    }
  }

  /// 전문가 계정 생성
  Future<ExpertAccountModel> createExpertAccount({
    required String userId,
    String? expertPublicId,
  }) async {
    try {
      debugPrint('📝 ExpertAccountDataSource: create($userId)');
      final now = DateTime.now();
      final data = {
        'userId': userId,
        'expertPublicId': expertPublicId,
        'isVerified': false,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _collection.add(data);
      debugPrint('   → 생성 완료: ${docRef.id}');

      return ExpertAccountModel.fromJson({
        'id': docRef.id,
        ...data,
      });
    } catch (e) {
      debugPrint('❌ ExpertAccountDataSource.create error: $e');
      rethrow;
    }
  }

  /// 전문가 계정 업데이트
  Future<void> updateExpertAccount(ExpertAccountModel account) async {
    try {
      debugPrint('📝 ExpertAccountDataSource: update(${account.id})');
      await _collection.doc(account.id).update({
        'expertPublicId': account.expertPublicId,
        'isVerified': account.isVerified,
        'status': account.status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      debugPrint('   → 업데이트 완료');
    } catch (e) {
      debugPrint('❌ ExpertAccountDataSource.update error: $e');
      rethrow;
    }
  }

  /// 전문가 인증 승인
  Future<void> approveExpertAccount(String accountId) async {
    try {
      debugPrint('✅ ExpertAccountDataSource: approve($accountId)');
      await _collection.doc(accountId).update({
        'isVerified': true,
        'status': 'active',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      debugPrint('   → 승인 완료');
    } catch (e) {
      debugPrint('❌ ExpertAccountDataSource.approve error: $e');
      rethrow;
    }
  }
}




