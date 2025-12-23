import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/repositories/case_repository.dart';
import '../models/legal_case_model.dart';

/// 사건 레포지토리 구현체 (Firebase)
class CaseRepositoryImpl implements CaseRepository {
  final FirebaseFirestore _firestore;

  CaseRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Firestore 사건 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _casesCollection =>
      _firestore.collection('cases');

  @override
  Future<List<LegalCase>> getUserCases(String userId) async {
    try {
      final snapshot = await _casesCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return LegalCaseModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<LegalCase> getCaseById(String id) async {
    try {
      final doc = await _casesCollection.doc(id).get();

      if (!doc.exists) {
        throw Exception('사건을 찾을 수 없습니다');
      }

      return LegalCaseModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      throw Exception('사건 정보를 불러오는데 실패했습니다');
    }
  }

  @override
  Future<LegalCase> createCase({
    required String userId,
    required String category,
    required String urgency,
    required String title,
    required String description,
  }) async {
    try {
      final caseData = {
        'user_id': userId,
        'category': category,
        'urgency': urgency,
        'title': title,
        'description': description,
        'status': CaseStatus.pending.name,
        'assigned_expert': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': null,
      };

      final docRef = await _casesCollection.add(caseData);

      return LegalCaseModel.fromJson({
        'id': docRef.id,
        ...caseData,
      });
    } catch (e) {
      throw Exception('사건 등록에 실패했습니다');
    }
  }

  @override
  Future<LegalCase> updateCase(LegalCase legalCase) async {
    try {
      final updateData = {
        'category': legalCase.category,
        'urgency': legalCase.urgency,
        'title': legalCase.title,
        'description': legalCase.description,
        'status': legalCase.status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _casesCollection.doc(legalCase.id).update(updateData);

      return legalCase.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw Exception('사건 수정에 실패했습니다');
    }
  }

  @override
  Future<void> deleteCase(String id) async {
    try {
      await _casesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('사건 삭제에 실패했습니다');
    }
  }

  @override
  Future<LegalCase> assignExpert({
    required String caseId,
    required int expertId,
  }) async {
    try {
      // 전문가 정보 가져오기
      final expertDoc = await _firestore
          .collection('experts')
          .where('id', isEqualTo: expertId)
          .limit(1)
          .get();

      Map<String, dynamic>? expertData;
      if (expertDoc.docs.isNotEmpty) {
        final data = expertDoc.docs.first.data();
        expertData = {
          'id': expertId,
          'name': data['name'],
          'profile_image': data['profile_image'],
          'specialty': data['specialty'],
        };
      }

      await _casesCollection.doc(caseId).update({
        'assigned_expert': expertData,
        'status': CaseStatus.inProgress.name,
        'updated_at': DateTime.now().toIso8601String(),
      });

      final doc = await _casesCollection.doc(caseId).get();
      return LegalCaseModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      throw Exception('전문가 배정에 실패했습니다');
    }
  }
}
