import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/domain/usecases/submit_document_certification_usecase.dart';
import 'package:law_decode/domain/usecases/submit_instant_certification_usecase.dart';
import 'package:law_decode/domain/usecases/create_expert_account_usecase.dart';
import 'package:law_decode/domain/usecases/get_expert_account_usecase.dart';
import 'expert_certification_event.dart';
import 'expert_certification_state.dart';

/// ExpertCertification Bloc
class ExpertCertificationBloc
    extends Bloc<ExpertCertificationEvent, ExpertCertificationState> {
  final SubmitDocumentCertificationUseCase _submitDocumentCertificationUseCase;
  final SubmitInstantCertificationUseCase _submitInstantCertificationUseCase;
  final CreateExpertAccountUseCase _createExpertAccountUseCase;
  final GetExpertAccountUseCase _getExpertAccountUseCase;

  ExpertCertificationBloc({
    required SubmitDocumentCertificationUseCase
        submitDocumentCertificationUseCase,
    required SubmitInstantCertificationUseCase submitInstantCertificationUseCase,
    required CreateExpertAccountUseCase createExpertAccountUseCase,
    required GetExpertAccountUseCase getExpertAccountUseCase,
  })  : _submitDocumentCertificationUseCase = submitDocumentCertificationUseCase,
        _submitInstantCertificationUseCase = submitInstantCertificationUseCase,
        _createExpertAccountUseCase = createExpertAccountUseCase,
        _getExpertAccountUseCase = getExpertAccountUseCase,
        super(CertificationInitial()) {
    on<SubmitDocumentCertification>(_onSubmitDocumentCertification);
    on<SubmitInstantCertification>(_onSubmitInstantCertification);
  }

  Future<void> _onSubmitDocumentCertification(
    SubmitDocumentCertification event,
    Emitter<ExpertCertificationState> emit,
  ) async {
    emit(CertificationSubmitting());

    try {
      debugPrint('📝 ExpertCertificationBloc: Submitting document certification');

      // 1. expert_accounts가 없으면 생성
      var account = await _getExpertAccountUseCase(event.userId);
      if (account == null) {
        debugPrint('   → expert_account 생성');
        account = await _createExpertAccountUseCase(userId: event.userId);
      }

      // 2. 서류 인증 제출
      final certification = await _submitDocumentCertificationUseCase(
        userId: event.userId,
        idCardFile: event.idCardFile,
        licenseFile: event.licenseFile,
        expertAccountId: account.id,
      );

      debugPrint('   → 서류 인증 제출 완료: ${certification.id}');
      emit(CertificationSuccess(certification));
    } catch (e) {
      debugPrint('❌ ExpertCertificationBloc.submitDocument error: $e');
      emit(CertificationFailure(e.toString()));
    }
  }

  Future<void> _onSubmitInstantCertification(
    SubmitInstantCertification event,
    Emitter<ExpertCertificationState> emit,
  ) async {
    emit(CertificationSubmitting());

    try {
      debugPrint('📝 ExpertCertificationBloc: Submitting instant certification');

      // 1. expert_accounts가 없으면 생성
      var account = await _getExpertAccountUseCase(event.userId);
      if (account == null) {
        debugPrint('   → expert_account 생성');
        account = await _createExpertAccountUseCase(userId: event.userId);
      }

      // 2. 즉시 인증 제출
      final certification = await _submitInstantCertificationUseCase(
        userId: event.userId,
        registrationNumber: event.registrationNumber,
        idNumber: event.idNumber,
        expertAccountId: account.id,
      );

      debugPrint('   → 즉시 인증 제출 완료: ${certification.id}');
      emit(CertificationSuccess(certification));
    } catch (e) {
      debugPrint('❌ ExpertCertificationBloc.submitInstant error: $e');
      emit(CertificationFailure(e.toString()));
    }
  }
}























