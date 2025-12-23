import 'package:equatable/equatable.dart';

/// 전문가 이벤트
abstract class ExpertEvent extends Equatable {
  const ExpertEvent();

  @override
  List<Object?> get props => [];
}

/// 전문가 목록 로드
class ExpertListRequested extends ExpertEvent {
  final String? category;
  final String? urgency;

  const ExpertListRequested({this.category, this.urgency});

  @override
  List<Object?> get props => [category, urgency];
}

/// 전문가 상세 로드
class ExpertDetailRequested extends ExpertEvent {
  final int expertId;

  const ExpertDetailRequested(this.expertId);

  @override
  List<Object?> get props => [expertId];
}

/// 전문가 검색
class ExpertSearchRequested extends ExpertEvent {
  final String query;

  const ExpertSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// 에러 초기화
class ExpertErrorCleared extends ExpertEvent {}


