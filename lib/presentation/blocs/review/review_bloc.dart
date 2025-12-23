import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/review_repository_impl.dart';
import 'review_event.dart';
import 'review_state.dart';

/// 리뷰 BLoC
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepositoryImpl _reviewRepository;

  ReviewBloc({ReviewRepositoryImpl? reviewRepository})
      : _reviewRepository = reviewRepository ?? ReviewRepositoryImpl(),
        super(ReviewInitial()) {
    on<ReviewExpertListRequested>(_onExpertListRequested);
    on<ReviewUserListRequested>(_onUserListRequested);
    on<ReviewCreateRequested>(_onCreateRequested);
    on<ReviewDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onExpertListRequested(
    ReviewExpertListRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final reviews = await _reviewRepository.getExpertReviews(event.expertId);
      if (reviews.isEmpty) {
        emit(ReviewEmpty());
      } else {
        emit(ReviewListLoaded(reviews));
      }
    } catch (e) {
      emit(ReviewError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUserListRequested(
    ReviewUserListRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final reviews = await _reviewRepository.getUserReviews(event.userId);
      if (reviews.isEmpty) {
        emit(ReviewEmpty());
      } else {
        emit(ReviewListLoaded(reviews));
      }
    } catch (e) {
      emit(ReviewError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreateRequested(
    ReviewCreateRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      await _reviewRepository.createReview(
        userId: event.userId,
        expertId: event.expertId,
        caseId: event.caseId,
        rating: event.rating,
        content: event.content,
      );
      emit(ReviewCreated());
    } catch (e) {
      emit(ReviewError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteRequested(
    ReviewDeleteRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      await _reviewRepository.deleteReview(event.reviewId);
      emit(ReviewDeleted());
    } catch (e) {
      emit(ReviewError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}


