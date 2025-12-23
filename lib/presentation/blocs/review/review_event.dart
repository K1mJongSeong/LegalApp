import 'package:equatable/equatable.dart';

/// 리뷰 이벤트
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// 전문가 리뷰 목록 로드
class ReviewExpertListRequested extends ReviewEvent {
  final int expertId;

  const ReviewExpertListRequested(this.expertId);

  @override
  List<Object?> get props => [expertId];
}

/// 사용자 리뷰 목록 로드
class ReviewUserListRequested extends ReviewEvent {
  final String userId;

  const ReviewUserListRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 리뷰 작성
class ReviewCreateRequested extends ReviewEvent {
  final String userId;
  final int expertId;
  final String caseId;
  final double rating;
  final String content;

  const ReviewCreateRequested({
    required this.userId,
    required this.expertId,
    required this.caseId,
    required this.rating,
    required this.content,
  });

  @override
  List<Object?> get props => [userId, expertId, caseId, rating, content];
}

/// 리뷰 삭제
class ReviewDeleteRequested extends ReviewEvent {
  final String reviewId;

  const ReviewDeleteRequested(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}


