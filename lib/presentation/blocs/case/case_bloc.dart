import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/case_repository_impl.dart';
import 'case_event.dart';
import 'case_state.dart';

/// 사건 BLoC
class CaseBloc extends Bloc<CaseEvent, CaseState> {
  final CaseRepositoryImpl _caseRepository;

  CaseBloc({CaseRepositoryImpl? caseRepository})
      : _caseRepository = caseRepository ?? CaseRepositoryImpl(),
        super(CaseInitial()) {
    on<CaseListRequested>(_onListRequested);
    on<CaseDetailRequested>(_onDetailRequested);
    on<CaseCreateRequested>(_onCreateRequested);
    on<CaseExpertAssigned>(_onExpertAssigned);
    on<CaseDeleteRequested>(_onDeleteRequested);
    on<CaseErrorCleared>(_onErrorCleared);
  }

  Future<void> _onListRequested(
    CaseListRequested event,
    Emitter<CaseState> emit,
  ) async {
    emit(CaseLoading());
    try {
      final cases = await _caseRepository.getUserCases(event.userId);
      if (cases.isEmpty) {
        emit(CaseEmpty());
      } else {
        emit(CaseListLoaded(cases));
      }
    } catch (e) {
      emit(CaseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDetailRequested(
    CaseDetailRequested event,
    Emitter<CaseState> emit,
  ) async {
    emit(CaseLoading());
    try {
      final legalCase = await _caseRepository.getCaseById(event.caseId);
      emit(CaseDetailLoaded(legalCase));
    } catch (e) {
      emit(CaseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreateRequested(
    CaseCreateRequested event,
    Emitter<CaseState> emit,
  ) async {
    emit(CaseLoading());
    try {
      final legalCase = await _caseRepository.createCase(
        userId: event.userId,
        category: event.category,
        urgency: event.urgency,
        title: event.title,
        description: event.description,
      );
      emit(CaseCreated(legalCase));
    } catch (e) {
      emit(CaseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onExpertAssigned(
    CaseExpertAssigned event,
    Emitter<CaseState> emit,
  ) async {
    emit(CaseLoading());
    try {
      final legalCase = await _caseRepository.assignExpert(
        caseId: event.caseId,
        expertId: event.expertId,
      );
      emit(CaseDetailLoaded(legalCase));
    } catch (e) {
      emit(CaseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteRequested(
    CaseDeleteRequested event,
    Emitter<CaseState> emit,
  ) async {
    emit(CaseLoading());
    try {
      await _caseRepository.deleteCase(event.caseId);
      emit(CaseDeleted());
    } catch (e) {
      emit(CaseError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onErrorCleared(
    CaseErrorCleared event,
    Emitter<CaseState> emit,
  ) {
    emit(CaseInitial());
  }
}


