import 'package:equatable/equatable.dart';

/// ExpertDashboard Events
abstract class ExpertDashboardEvent extends Equatable {
  const ExpertDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// 전문가 대시보드 로드
class LoadExpertDashboard extends ExpertDashboardEvent {
  final String userId;

  const LoadExpertDashboard(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 전문가 대시보드 새로고침
class RefreshExpertDashboard extends ExpertDashboardEvent {
  final String userId;

  const RefreshExpertDashboard(this.userId);

  @override
  List<Object?> get props => [userId];
}








