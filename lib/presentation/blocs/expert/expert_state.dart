import 'package:equatable/equatable.dart';
import '../../../domain/entities/expert.dart';

/// 전문가 상태
abstract class ExpertState extends Equatable {
  const ExpertState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class ExpertInitial extends ExpertState {}

/// 로딩 중
class ExpertLoading extends ExpertState {}

/// 전문가 목록 로드됨
class ExpertListLoaded extends ExpertState {
  final List<Expert> experts;

  const ExpertListLoaded(this.experts);

  @override
  List<Object?> get props => [experts];
}

/// 전문가 상세 로드됨
class ExpertDetailLoaded extends ExpertState {
  final Expert expert;

  const ExpertDetailLoaded(this.expert);

  @override
  List<Object?> get props => [expert];
}

/// 전문가 목록 비어있음
class ExpertEmpty extends ExpertState {}

/// 에러
class ExpertError extends ExpertState {
  final String message;

  const ExpertError(this.message);

  @override
  List<Object?> get props => [message];
}


