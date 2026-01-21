import 'package:law_decode/domain/entities/expert_account.dart';
import 'package:law_decode/domain/repositories/expert_account_repository.dart';

/// 전문가 계정 조회 UseCase
class GetExpertAccountUseCase {
  final ExpertAccountRepository _repository;

  GetExpertAccountUseCase(this._repository);

  Future<ExpertAccount?> call(String userId) async {
    return await _repository.getExpertAccountByUserId(userId);
  }
}



















