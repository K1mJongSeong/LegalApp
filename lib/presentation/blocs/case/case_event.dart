import 'package:equatable/equatable.dart';
import '../../../domain/entities/legal_case.dart';

/// 사건 이벤트
abstract class CaseEvent extends Equatable {
  const CaseEvent();

  @override
  List<Object?> get props => [];
}

/// 사용자 사건 목록 로드
class CaseListRequested extends CaseEvent {
  final String userId;

  const CaseListRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 사건 상세 로드
class CaseDetailRequested extends CaseEvent {
  final String caseId;

  const CaseDetailRequested(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

/// 새 사건 생성
class CaseCreateRequested extends CaseEvent {
  final String userId;
  final String category;
  final String urgency;
  final String title;
  final String description;

  const CaseCreateRequested({
    required this.userId,
    required this.category,
    required this.urgency,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [userId, category, urgency, title, description];
}

/// 전문가 배정
class CaseExpertAssigned extends CaseEvent {
  final String caseId;
  final int expertId;

  const CaseExpertAssigned({
    required this.caseId,
    required this.expertId,
  });

  @override
  List<Object?> get props => [caseId, expertId];
}

/// 사건 삭제
class CaseDeleteRequested extends CaseEvent {
  final String caseId;

  const CaseDeleteRequested(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

/// 에러 초기화
class CaseErrorCleared extends CaseEvent {}


