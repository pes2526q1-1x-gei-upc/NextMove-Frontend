import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';
import 'assessment_event.dart';
import 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository assessmentRepository;

  AssessmentBloc({required this.assessmentRepository})
    : super(const AssessmentState()) {
    on<CreateAssessmentEvent>(_onCreateAssessment);
    on<GetAssessmentsByStationEvent>(_onGetAssessments);
    on<GetStationAssessmentInfoEvent>(_onGetAssessmentInfo);
    on<UpdateAssessmentEvent>(_onUpdateAssessment);
    on<DeleteAssessmentEvent>(_onDeleteAssessment);
    on<CheckAssessedEvent>(_onCheckAssessed);
  }

  // --- OBTENER LISTA ---
  Future<void> _onGetAssessments(
    GetAssessmentsByStationEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    if (state.assessments.isEmpty) {
      emit(state.copyWith(status: AssessmentStatus.loading));
    }
    final result = await assessmentRepository.getAssessmentsByStation(
      event.stationId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (assessmentsList) => emit(
        state.copyWith(
          status: AssessmentStatus.success,
          assessments: assessmentsList,
        ),
      ),
    );
  }

  // --- OBTENER INFO (MEDIA Y TOTAL) ---
  Future<void> _onGetAssessmentInfo(
    GetStationAssessmentInfoEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    final result = await assessmentRepository.getStationAssessmentInfo(
      event.stationId,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (info) => emit(
        state.copyWith(
          averageScore: info.averageScore,
          totalAssessments: info.totalAssessments,
        ),
      ),
    );
  }

  // --- CREAR ---
  Future<void> _onCreateAssessment(
    CreateAssessmentEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));
    final result = await assessmentRepository.createAssessment(
      stationId: event.stationId,
      score: event.score,
      comment: event.comment,
    );

    result.fold(
<<<<<<< Updated upstream
      (failure) => emit(
        state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ),
      ),
=======
      (failure) {
        debugPrint('Error en createAssessment: ${failure.message}');
        emit(state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ));
      },
>>>>>>> Stashed changes
      (_) {
        add(GetAssessmentsByStationEvent(stationId: event.stationId));
        add(GetStationAssessmentInfoEvent(stationId: event.stationId));
        add(CheckAssessedEvent(stationId: event.stationId));
        emit(state.copyWith(status: AssessmentStatus.success));
      },
    );
  }

  // --- ACTUALIZAR ---
  Future<void> _onUpdateAssessment(
    UpdateAssessmentEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));
    final result = await assessmentRepository.updateAssessment(
      stationId: event.stationId,
      score: event.score,
      comment: event.comment,
    );

    result.fold(
<<<<<<< Updated upstream
      (failure) => emit(
        state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ),
      ),
=======
      (failure) {
        debugPrint('Error en updateAssessment: ${failure.message}');
        emit(state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ));
      },
>>>>>>> Stashed changes
      (_) {
        add(GetAssessmentsByStationEvent(stationId: event.stationId));
        add(GetStationAssessmentInfoEvent(stationId: event.stationId));
        add(CheckAssessedEvent(stationId: event.stationId));
        emit(state.copyWith(status: AssessmentStatus.success));
      },
    );
  }

  // --- ELIMINAR ---
  Future<void> _onDeleteAssessment(
    DeleteAssessmentEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));
    final result = await assessmentRepository.deleteAssessment(event.stationId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final newTotal = (state.totalAssessments - 1) < 0
            ? 0
            : state.totalAssessments - 1;

        emit(
          state.copyWith(
            status: AssessmentStatus.success,
            totalAssessments: newTotal,
            averageScore: newTotal == 0 ? 0.0 : state.averageScore,
          ),
        );

        add(GetAssessmentsByStationEvent(stationId: event.stationId));
        add(GetStationAssessmentInfoEvent(stationId: event.stationId));
        add(CheckAssessedEvent(stationId: event.stationId));
      },
    );
  }

  // --- CHECK IF USER HAS ASSESSED ---
  Future<void> _onCheckAssessed(
    CheckAssessedEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    final result = await assessmentRepository.checkAssessed(event.stationId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (hasAssessed) => emit(state.copyWith(userHasAssessed: hasAssessed)),
    );
  }
}
