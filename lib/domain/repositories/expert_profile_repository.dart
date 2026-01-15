import '../entities/expert_profile.dart';

/// 전문가 프로필 저장소 인터페이스
abstract class ExpertProfileRepository {
  /// 프로필 조회 (userId로)
  Future<ExpertProfile?> getProfileByUserId(String userId);

  /// 프로필 저장/업데이트
  Future<void> saveProfile(ExpertProfile profile);

  /// 프로필 이미지 URL 업데이트
  Future<void> updateProfileImageUrl(String userId, String imageUrl);
}






