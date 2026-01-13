import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/data/models/consultation_request_model.dart';

/// ConsultationRequest Firebase DataSource
class ConsultationRequestRemoteDataSource {
  final FirebaseFirestore _firestore;

  ConsultationRequestRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('consultation_requests');

  /// 전문가 계정 ID로 상담 요청 목록 조회
  Future<List<ConsultationRequestModel>> getConsultationRequestsByExpertAccountId(
    String expertAccountId,
  ) async {
    try {
      debugPrint('🔍 ConsultationRequestDataSource: getByExpertAccountId($expertAccountId)');
      final snapshot = await _collection
          .where('expertAccountId', isEqualTo: expertAccountId)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('   → ${snapshot.docs.length}건 발견');
      return snapshot.docs.map((doc) {
        return ConsultationRequestModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ ConsultationRequestDataSource.getByExpertAccountId error: $e');
      return [];
    }
  }

  /// 상담 요청 상태 업데이트
  Future<void> updateConsultationStatus({
    required String requestId,
    required String status,
  }) async {
    try {
      debugPrint('📝 ConsultationRequestDataSource: updateStatus($requestId, $status)');
      await _collection.doc(requestId).update({
        'status': status,
      });
      debugPrint('   → 상태 업데이트 완료');
    } catch (e) {
      debugPrint('❌ ConsultationRequestDataSource.updateStatus error: $e');
      rethrow;
    }
  }
}











