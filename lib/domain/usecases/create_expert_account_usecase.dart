import 'package:law_decode/domain/entities/expert_account.dart';
import 'package:law_decode/domain/repositories/expert_account_repository.dart';

/// 전문가 계정 생성 UseCase
class CreateExpertAccountUseCase {
  final ExpertAccountRepository _repository;

  CreateExpertAccountUseCase(this._repository);

  Future<ExpertAccount> call({
    required String userId,
    String? expertPublicId,
  }) async {
    return await _repository.createExpertAccount(
      userId: userId,
      expertPublicId: expertPublicId,
    );
  }
}





