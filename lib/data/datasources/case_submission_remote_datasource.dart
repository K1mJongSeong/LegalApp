import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 사건 전송 Firebase DataSource
class CaseSubmissionRemoteDataSource {
  final FirebaseFirestore _firestore;

  CaseSubmissionRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _submissionsCollection =>
      _firestore.collection('case_submissions');

  CollectionReference<Map<String, dynamic>> get _statsCollection =>
      _firestore.collection('case_submission_stats');

  /// 사건 전송 정보 저장
  Future<void> createCaseSubmission({
    required String userId,
    required String consultationPostId,
    required String expertUserId,
    String? expertId,
  }) async {
    try {
      debugPrint('📝 CaseSubmissionDataSource: create');
      final now = DateTime.now();
      final data = {
        'userId': userId,
        'consultationPostId': consultationPostId,
        'expertUserId': expertUserId,
        'expertId': expertId,
        'createdAt': Timestamp.fromDate(now),
      };

      await _submissionsCollection.add(data);
      debugPrint('   → 사건 전송 정보 저장 완료');
    } catch (e) {
      debugPrint('❌ CaseSubmissionDataSource.create error: $e');
      rethrow;
    }
  }

  /// 사건 전송 통계 집계 (버튼 클릭 수 증가)
  Future<void> incrementSubmissionCount() async {
    try {
      debugPrint('📊 CaseSubmissionDataSource: incrementSubmissionCount');
      
      // 오늘 날짜를 키로 사용
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final statsDocRef = _statsCollection.doc('daily');
      
      // 트랜잭션으로 안전하게 증가
      await _firestore.runTransaction((transaction) async {
        final statsDoc = await transaction.get(statsDocRef);
        
        if (!statsDoc.exists) {
          // 문서가 없으면 생성
          transaction.set(statsDocRef, {
            'totalCount': 1,
            'dailyCounts': {
              dateKey: 1,
            },
            'lastUpdated': Timestamp.fromDate(today),
          });
        } else {
          // 문서가 있으면 카운트 증가
          final currentData = statsDoc.data()!;
          final totalCount = (currentData['totalCount'] as int? ?? 0) + 1;
          final dailyCounts = Map<String, dynamic>.from(
            currentData['dailyCounts'] as Map? ?? {},
          );
          final currentDayCount = (dailyCounts[dateKey] as int? ?? 0) + 1;
          dailyCounts[dateKey] = currentDayCount;
          
          transaction.update(statsDocRef, {
            'totalCount': totalCount,
            'dailyCounts': dailyCounts,
            'lastUpdated': Timestamp.fromDate(today),
          });
        }
      });
      
      debugPrint('   → 통계 집계 완료');
    } catch (e) {
      debugPrint('❌ CaseSubmissionDataSource.incrementSubmissionCount error: $e');
      // 통계 집계 실패해도 사건 전송은 성공으로 처리
    }
  }
}









