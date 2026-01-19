import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/expert_repository_impl.dart';
import 'expert_event.dart';
import 'expert_state.dart';

/// 전문가 BLoC
class ExpertBloc extends Bloc<ExpertEvent, ExpertState> {
  final ExpertRepositoryImpl _expertRepository;

  ExpertBloc({ExpertRepositoryImpl? expertRepository})
      : _expertRepository = expertRepository ?? ExpertRepositoryImpl(),
        super(ExpertInitial()) {
    on<ExpertListRequested>(_onListRequested);
    on<ExpertDetailRequested>(_onDetailRequested);
    on<ExpertDetailByUserIdRequested>(_onDetailByUserIdRequested);
    on<ExpertSearchRequested>(_onSearchRequested);
    on<ExpertErrorCleared>(_onErrorCleared);
  }

  Future<void> _onListRequested(
    ExpertListRequested event,
    Emitter<ExpertState> emit,
  ) async {
    emit(ExpertLoading());
    try {
      // 인증된 전문가만 조회 (isVerified: true, status: "active")
      final experts = await _expertRepository.getVerifiedExperts(
        category: event.category,
      );
      if (experts.isEmpty) {
        emit(ExpertEmpty());
      } else {
        emit(ExpertListLoaded(experts));
      }
    } catch (e) {
      emit(ExpertError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDetailRequested(
    ExpertDetailRequested event,
    Emitter<ExpertState> emit,
  ) async {
    emit(ExpertLoading());
    try {
      final expert = await _expertRepository.getExpertById(event.expertId);
      emit(ExpertDetailLoaded(expert));
    } catch (e) {
      emit(ExpertError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDetailByUserIdRequested(
    ExpertDetailByUserIdRequested event,
    Emitter<ExpertState> emit,
  ) async {
    emit(ExpertLoading());
    try {
      final expert = await _expertRepository.getExpertByUserId(event.userId);
      if (expert != null) {
        emit(ExpertDetailLoaded(expert));
      } else {
        emit(ExpertError('전문가를 찾을 수 없습니다'));
      }
    } catch (e) {
      emit(ExpertError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSearchRequested(
    ExpertSearchRequested event,
    Emitter<ExpertState> emit,
  ) async {
    emit(ExpertLoading());
    try {
      final experts = await _expertRepository.searchExperts(event.query);
      if (experts.isEmpty) {
        emit(ExpertEmpty());
      } else {
        emit(ExpertListLoaded(experts));
      }
    } catch (e) {
      emit(ExpertError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onErrorCleared(
    ExpertErrorCleared event,
    Emitter<ExpertState> emit,
  ) {
    emit(ExpertInitial());
  }
}
