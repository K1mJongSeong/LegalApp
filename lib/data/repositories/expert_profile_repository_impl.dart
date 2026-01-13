import '../../domain/entities/expert_profile.dart';
import '../../domain/repositories/expert_profile_repository.dart';
import '../datasources/expert_profile_remote_datasource.dart';

/// 전문가 프로필 저장소 구현
class ExpertProfileRepositoryImpl implements ExpertProfileRepository {
  final ExpertProfileRemoteDataSource _remoteDataSource;

  ExpertProfileRepositoryImpl({
    ExpertProfileRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ExpertProfileRemoteDataSource();

  @override
  Future<ExpertProfile?> getProfileByUserId(String userId) async {
    return await _remoteDataSource.getProfileByUserId(userId);
  }

  @override
  Future<void> saveProfile(ExpertProfile profile) async {
    return await _remoteDataSource.saveProfile(profile);
  }

  @override
  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    return await _remoteDataSource.updateProfileImageUrl(userId, imageUrl);
  }
}



