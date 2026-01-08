import 'package:law_decode/data/datasources/expert_account_remote_datasource.dart';
import 'package:law_decode/domain/entities/expert_account.dart';
import 'package:law_decode/domain/repositories/expert_account_repository.dart';

/// ExpertAccount Repository 구현체
class ExpertAccountRepositoryImpl implements ExpertAccountRepository {
  final ExpertAccountRemoteDataSource _remoteDataSource;

  ExpertAccountRepositoryImpl(this._remoteDataSource);

  @override
  Future<ExpertAccount?> getExpertAccountByUserId(String userId) async {
    return await _remoteDataSource.getExpertAccountByUserId(userId);
  }

  @override
  Future<ExpertAccount> createExpertAccount({
    required String userId,
    String? expertPublicId,
  }) async {
    return await _remoteDataSource.createExpertAccount(
      userId: userId,
      expertPublicId: expertPublicId,
    );
  }

  @override
  Future<void> updateExpertAccount(ExpertAccount account) async {
    // Entity를 Model로 변환 후 업데이트
    final model = account;
    await _remoteDataSource.updateExpertAccount(model as dynamic);
  }

  @override
  Future<void> approveExpertAccount(String accountId) async {
    return await _remoteDataSource.approveExpertAccount(accountId);
  }
}





