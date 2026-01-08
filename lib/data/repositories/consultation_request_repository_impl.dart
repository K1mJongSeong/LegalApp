import 'package:law_decode/data/datasources/consultation_request_remote_datasource.dart';
import 'package:law_decode/domain/entities/consultation_request.dart';
import 'package:law_decode/domain/repositories/consultation_request_repository.dart';

/// ConsultationRequest Repository 구현체
class ConsultationRequestRepositoryImpl
    implements ConsultationRequestRepository {
  final ConsultationRequestRemoteDataSource _remoteDataSource;

  ConsultationRequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ConsultationRequest>> getConsultationRequestsByExpertAccountId(
    String expertAccountId,
  ) async {
    return await _remoteDataSource.getConsultationRequestsByExpertAccountId(
      expertAccountId,
    );
  }

  @override
  Future<void> updateConsultationStatus({
    required String requestId,
    required String status,
  }) async {
    return await _remoteDataSource.updateConsultationStatus(
      requestId: requestId,
      status: status,
    );
  }
}





