import 'package:equatable/equatable.dart';
import '../../../domain/entities/review.dart';

/// 리뷰 상태
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class ReviewInitial extends ReviewState {}

/// 로딩 중
class ReviewLoading extends ReviewState {}

/// 리뷰 목록 로드됨
class ReviewListLoaded extends ReviewState {
  final List<Review> reviews;

  const ReviewListLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

/// 리뷰 목록 비어있음
class ReviewEmpty extends ReviewState {}

/// 리뷰 생성 성공
class ReviewCreated extends ReviewState {}

/// 리뷰 삭제 성공
class ReviewDeleted extends ReviewState {}

/// 에러
class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}


