import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/data/models/expert_certification_model.dart';

/// ExpertCertification Firebase DataSource
class ExpertCertificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ExpertCertificationRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('expert_certifications');

  /// 파일 업로드 (Firebase Storage)
  Future<String> _uploadFile(File file, String path) async {
    try {
      debugPrint('📤 Uploading file to: $path');
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      debugPrint('   → Upload success: $url');
      return url;
    } catch (e) {
      debugPrint('❌ File upload error: $e');
      rethrow;
    }
  }

  /// 서류 인증 신청
  Future<ExpertCertificationModel> submitDocumentCertification({
    required String userId,
    required File idCardFile,
    required File licenseFile,
    String? expertAccountId,
  }) async {
    try {
      debugPrint('📝 CertificationDataSource: submitDocument($userId)');

      // 1. 파일 업로드
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final idCardUrl = await _uploadFile(
        idCardFile,
        'expert_certifications/$userId/id_card_$timestamp.jpg',
      );
      final licenseUrl = await _uploadFile(
        licenseFile,
        'expert_certifications/$userId/license_$timestamp.jpg',
      );

      // 2. Firestore에 저장
      final now = DateTime.now();
      final data = {
        'userId': userId,
        'expertAccountId': expertAccountId,
        'type': 'document',
        'idCardUrl': idCardUrl,
        'licenseUrl': licenseUrl,
        'status': 'pending',
        'submittedAt': Timestamp.fromDate(now),
      };

      final docRef = await _collection.add(data);
      debugPrint('   → 인증 신청 완료: ${docRef.id}');

      return ExpertCertificationModel.fromJson({
        'id': docRef.id,
        ...data,
      });
    } catch (e) {
      debugPrint('❌ CertificationDataSource.submitDocument error: $e');
      rethrow;
    }
  }

  /// 즉시 인증 신청
  Future<ExpertCertificationModel> submitInstantCertification({
    required String userId,
    required String registrationNumber,
    required String idNumber,
    String? expertAccountId,
  }) async {
    try {
      debugPrint('📝 CertificationDataSource: submitInstant($userId)');

      final now = DateTime.now();
      final data = {
        'userId': userId,
        'expertAccountId': expertAccountId,
        'type': 'instant',
        'registrationNumber': registrationNumber,
        'idNumber': idNumber,
        'status': 'pending',
        'submittedAt': Timestamp.fromDate(now),
      };

      final docRef = await _collection.add(data);
      debugPrint('   → 즉시 인증 신청 완료: ${docRef.id}');

      return ExpertCertificationModel.fromJson({
        'id': docRef.id,
        ...data,
      });
    } catch (e) {
      debugPrint('❌ CertificationDataSource.submitInstant error: $e');
      rethrow;
    }
  }

  /// userId로 인증 신청 내역 조회
  Future<List<ExpertCertificationModel>> getCertificationsByUserId(
    String userId,
  ) async {
    try {
      debugPrint('🔍 CertificationDataSource: getByUserId($userId)');
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();

      debugPrint('   → ${snapshot.docs.length}건 발견');
      return snapshot.docs.map((doc) {
        return ExpertCertificationModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ CertificationDataSource.getByUserId error: $e');
      return [];
    }
  }

  /// 인증 상태 업데이트 (관리자용 - TODO)
  Future<void> updateCertificationStatus({
    required String certificationId,
    required String status,
    String? rejectReason,
  }) async {
    try {
      debugPrint('📝 CertificationDataSource: updateStatus($certificationId, $status)');
      await _collection.doc(certificationId).update({
        'status': status,
        'reviewedAt': Timestamp.fromDate(DateTime.now()),
        if (rejectReason != null) 'rejectReason': rejectReason,
      });
      debugPrint('   → 상태 업데이트 완료');
    } catch (e) {
      debugPrint('❌ CertificationDataSource.updateStatus error: $e');
      rethrow;
    }
  }
}






