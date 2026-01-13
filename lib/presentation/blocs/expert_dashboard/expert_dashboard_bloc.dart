import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:law_decode/domain/usecases/get_expert_account_usecase.dart';
import 'package:law_decode/domain/usecases/get_consultation_requests_usecase.dart';
import 'package:law_decode/domain/repositories/expert_repository.dart';
import 'expert_dashboard_event.dart';
import 'expert_dashboard_state.dart';

/// ExpertDashboard Bloc
class ExpertDashboardBloc
    extends Bloc<ExpertDashboardEvent, ExpertDashboardState> {
  final GetExpertAccountUseCase _getExpertAccountUseCase;
  final GetConsultationRequestsUseCase _getConsultationRequestsUseCase;
  final ExpertRepository _expertRepository;

  ExpertDashboardBloc({
    required GetExpertAccountUseCase getExpertAccountUseCase,
    required GetConsultationRequestsUseCase getConsultationRequestsUseCase,
    required ExpertRepository expertRepository,
  })  : _getExpertAccountUseCase = getExpertAccountUseCase,
        _getConsultationRequestsUseCase = getConsultationRequestsUseCase,
        _expertRepository = expertRepository,
        super(ExpertDashboardInitial()) {
    on<LoadExpertDashboard>(_onLoadExpertDashboard);
    on<RefreshExpertDashboard>(_onRefreshExpertDashboard);
  }

  Future<void> _onLoadExpertDashboard(
    LoadExpertDashboard event,
    Emitter<ExpertDashboardState> emit,
  ) async {
    emit(ExpertDashboardLoading());
    await _loadDashboard(event.userId, emit);
  }

  Future<void> _onRefreshExpertDashboard(
    RefreshExpertDashboard event,
    Emitter<ExpertDashboardState> emit,
  ) async {
    await _loadDashboard(event.userId, emit);
  }

  Future<void> _loadDashboard(
    String userId,
    Emitter<ExpertDashboardState> emit,
  ) async {
    try {
      debugPrint('🔍 ExpertDashboardBloc: Loading dashboard for $userId');

      // 1. expert_accounts 조회
      final account = await _getExpertAccountUseCase(userId);

      if (account == null) {
        debugPrint('   → 계정 없음: 인증 필요');
        emit(ExpertDashboardNeedsCertification());
        return;
      }

      // 2. 인증 상태 확인
      if (!account.isVerified) {
        debugPrint('   → 인증 대기 중');
        emit(ExpertDashboardVerificationPending(account));
        return;
      }

      // 3. 상담 요청 목록 조회
      final consultationRequests =
          await _getConsultationRequestsUseCase(account.id);

      final waitingCount =
          consultationRequests.where((r) => r.status == 'waiting').length;
      final acceptedCount =
          consultationRequests.where((r) => r.status == 'accepted').length;

      // 4. (선택) experts 공개 프로필 조회
      final publicProfile = account.expertPublicId != null
          ? await _expertRepository.getExpertById(
              int.tryParse(account.expertPublicId!) ?? 0)
          : null;

      debugPrint('   → 대시보드 로드 완료');
      debugPrint('      - 대기: $waitingCount, 수락: $acceptedCount');

      emit(ExpertDashboardLoaded(
        account: account,
        publicProfile: publicProfile,
        consultationRequests: consultationRequests,
        waitingCount: waitingCount,
        acceptedCount: acceptedCount,
      ));
    } catch (e) {
      debugPrint('❌ ExpertDashboardBloc error: $e');
      emit(ExpertDashboardError(e.toString()));
    }
  }
}












