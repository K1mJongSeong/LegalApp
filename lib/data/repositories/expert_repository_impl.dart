import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/expert.dart';
import '../../domain/entities/expert_profile.dart';
import '../../domain/repositories/expert_repository.dart';
import '../../domain/repositories/expert_account_repository.dart';
import '../../domain/repositories/expert_profile_repository.dart';
import '../datasources/expert_account_remote_datasource.dart';
import '../datasources/expert_profile_remote_datasource.dart';
import '../models/expert_model.dart';

/// 전문가 레포지토리 구현체 (Firebase)
class ExpertRepositoryImpl implements ExpertRepository {
  final FirebaseFirestore _firestore;
  final ExpertAccountRepository? _expertAccountRepository;
  final ExpertProfileRepository? _expertProfileRepository;

  ExpertRepositoryImpl({
    FirebaseFirestore? firestore,
    ExpertAccountRepository? expertAccountRepository,
    ExpertProfileRepository? expertProfileRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _expertAccountRepository = expertAccountRepository,
        _expertProfileRepository = expertProfileRepository;

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

  @override
  Future<List<Expert>> getVerifiedExperts({String? category}) async {
    try {
      debugPrint('🔍 ExpertRepository.getVerifiedExperts() called');
      
      // expert_accounts에서 인증된 전문가 계정 조회
      final accountDataSource = ExpertAccountRemoteDataSource();
      final verifiedAccounts = await accountDataSource.getVerifiedExpertAccounts();
      
      if (verifiedAccounts.isEmpty) {
        debugPrint('   → 인증된 전문가 없음');
        return [];
      }

      debugPrint('   → ${verifiedAccounts.length}명의 인증된 전문가 계정 발견');

      // 각 계정의 userId로 expert_profiles에서 프로필 조회
      final profileDataSource = ExpertProfileRemoteDataSource();
      final experts = <Expert>[];

      for (final account in verifiedAccounts) {
        try {
          final profile = await profileDataSource.getProfileByUserId(account.userId);
          
          if (profile == null) {
            debugPrint('   → 프로필 없음: ${account.userId}');
            continue;
          }

          // 카테고리 필터링
          if (category != null && category.isNotEmpty) {
            if (!profile.mainFields.contains(category)) {
              continue;
            }
          }

          // ExpertProfile을 Expert로 변환
          final expert = _convertProfileToExpert(profile, account.userId);
          experts.add(expert);
        } catch (e) {
          debugPrint('   → 프로필 조회 실패 (${account.userId}): $e');
          continue;
        }
      }

      debugPrint('   → ${experts.length}명의 전문가 반환');
      return experts;
    } catch (e) {
      debugPrint('❌ ExpertRepository.getVerifiedExperts error: $e');
      return [];
    }
  }

  /// ExpertProfile을 Expert 엔티티로 변환
  Expert _convertProfileToExpert(ExpertProfile profile, String userId) {
    // 경력 연수 계산 (careers에서 가장 오래된 경력의 시작 연도 기준)
    int experienceYears = 0;
    if (profile.careers.isNotEmpty) {
      final startYears = profile.careers
          .where((c) => c.startYear != null)
          .map((c) => c.startYear!)
          .toList();
      if (startYears.isNotEmpty) {
        final earliestYear = startYears.reduce((a, b) => a < b ? a : b);
        experienceYears = DateTime.now().year - earliestYear;
      }
    }

    // 직업 타입 결정 (examType 기반)
    String profession = '변호사';
    if (profile.examType != null) {
      if (profile.examType!.contains('노무사')) {
        profession = '노무사';
      } else if (profile.examType!.contains('변호사')) {
        profession = '변호사';
      }
    }

    // 소속 사무실
    String? lawFirm = profile.officeName;

    // 전문 분야 (한 줄 소개 또는 주요분야 첫 번째)
    String specialty = profile.oneLineIntro ?? 
        (profile.mainFields.isNotEmpty ? profile.mainFields.first : '법률 전문가');

    return Expert(
      id: userId.hashCode, // userId를 기반으로 ID 생성
      userId: userId, // userId 저장
      name: profile.name ?? '이름 없음',
      profileImage: profile.profileImageUrl,
      specialty: specialty,
      categories: profile.mainFields,
      experienceYears: experienceYears,
      rating: 0.0, // TODO: 리뷰 시스템 연동 시 업데이트
      reviewCount: 0, // TODO: 리뷰 시스템 연동 시 업데이트
      consultationCount: 0, // TODO: 상담 시스템 연동 시 업데이트
      introduction: profile.oneLineIntro,
      lawFirm: lawFirm,
      isAvailable: true, // 인증된 전문가는 모두 상담 가능
      profession: profession, // 직업 타입 저장
    );
  }
}
