import 'package:equatable/equatable.dart';
import '../../../domain/entities/legal_case.dart';

/// 사건 상태
abstract class CaseState extends Equatable {
  const CaseState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class CaseInitial extends CaseState {}

/// 로딩 중
class CaseLoading extends CaseState {}

/// 사건 목록 로드됨
class CaseListLoaded extends CaseState {
  final List<LegalCase> cases;

  const CaseListLoaded(this.cases);

  List<LegalCase> get pendingCases =>
      cases.where((c) => c.status == CaseStatus.pending).toList();

  List<LegalCase> get inProgressCases =>
      cases.where((c) => c.status == CaseStatus.inProgress).toList();

  List<LegalCase> get completedCases =>
      cases.where((c) => c.status == CaseStatus.completed).toList();

  @override
  List<Object?> get props => [cases];
}

/// 사건 상세 로드됨
class CaseDetailLoaded extends CaseState {
  final LegalCase legalCase;

  const CaseDetailLoaded(this.legalCase);

  @override
  List<Object?> get props => [legalCase];
}

/// 사건 목록 비어있음
class CaseEmpty extends CaseState {}

/// 사건 생성 성공
class CaseCreated extends CaseState {
  final LegalCase legalCase;

  const CaseCreated(this.legalCase);

  @override
  List<Object?> get props => [legalCase];
}

/// 사건 삭제 성공
class CaseDeleted extends CaseState {}

/// 에러
class CaseError extends CaseState {
  final String message;

  const CaseError(this.message);

  @override
  List<Object?> get props => [message];
}


