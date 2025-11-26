import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';
import 'assessment_event.dart';
import 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository assessmentRepository;

  AssessmentBloc({required this.assessmentRepository}) : super(const AssessmentState()) {
    on<CreateAssessmentEvent>(_onCreateAssessment);
  }

  Future<void> _onCreateAssessment(
    CreateAssessmentEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));
    debugPrint("Llegamos a evento, vamos a repository");
    final result = await assessmentRepository.createAssessment(
      stationId: event.stationId,
      score: event.score,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          status: AssessmentStatus.success,
          errorMessage: null, 
        ));
      },
    );
  }
}