import 'package:law_decode/domain/entities/expert_account.dart';

/// 전문가 계정 Repository Interface
abstract class ExpertAccountRepository {
  /// userId로 전문가 계정 조회
  Future<ExpertAccount?> getExpertAccountByUserId(String userId);

  /// 전문가 계정 생성
  Future<ExpertAccount> createExpertAccount({
    required String userId,
    String? expertPublicId,
  });

  /// 전문가 계정 업데이트
  Future<void> updateExpertAccount(ExpertAccount account);

  /// 전문가 인증 승인 (isVerified=true, status=active)
  Future<void> approveExpertAccount(String accountId);
}



