import 'package:equatable/equatable.dart';
import 'package:law_decode/domain/entities/expert_account.dart';
import 'package:law_decode/domain/entities/consultation_request.dart';
import 'package:law_decode/domain/entities/expert.dart';

/// ExpertDashboard States
abstract class ExpertDashboardState extends Equatable {
  const ExpertDashboardState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class ExpertDashboardInitial extends ExpertDashboardState {}

/// 로딩 중
class ExpertDashboardLoading extends ExpertDashboardState {}

/// 전문가 계정 없음 (인증 필요)
class ExpertDashboardNeedsCertification extends ExpertDashboardState {}

/// 인증 대기 중
class ExpertDashboardVerificationPending extends ExpertDashboardState {
  final ExpertAccount account;

  const ExpertDashboardVerificationPending(this.account);

  @override
  List<Object?> get props => [account];
}

/// 대시보드 로드 완료
class ExpertDashboardLoaded extends ExpertDashboardState {
  final ExpertAccount account;
  final Expert? publicProfile; // experts 컬렉션의 공개 프로필 (선택)
  final List<ConsultationRequest> consultationRequests;
  final int waitingCount; // 대기 중인 상담 요청 수
  final int acceptedCount; // 수락한 상담 요청 수

  const ExpertDashboardLoaded({
    required this.account,
    this.publicProfile,
    required this.consultationRequests,
    required this.waitingCount,
    required this.acceptedCount,
  });

  @override
  List<Object?> get props => [
        account,
        publicProfile,
        consultationRequests,
        waitingCount,
        acceptedCount,
      ];
}

/// 에러
class ExpertDashboardError extends ExpertDashboardState {
  final String message;

  const ExpertDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}













