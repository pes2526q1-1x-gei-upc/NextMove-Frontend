import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';
import 'assessment_event.dart';
import 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository assessmentRepository;

  AssessmentBloc({required this.assessmentRepository}) : super(const AssessmentState()) {
    on<CreateAssessmentEvent>(_onCreateAssessment);
    on<GetAssessmentsByStationEvent>(_onGetAssessments);
    on<GetStationAssessmentInfoEvent>(_onGetAssessmentInfo);
  }


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
      (failure) {
        emit(state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) {
        add(GetAssessmentsByStationEvent(stationId: event.stationId));
        
        emit(state.copyWith(
          status: AssessmentStatus.success,
          errorMessage: null,
        ));
      },
    );
  }


  Future<void> _onGetAssessments(
    GetAssessmentsByStationEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));

    final result = await assessmentRepository.getAssessmentsByStation(event.stationId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AssessmentStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (assessmentsList) {
        emit(state.copyWith(
          status: AssessmentStatus.success,
          assessments: assessmentsList, 
          errorMessage: null,
        ));
      },
    );
  }

Future<void> _onGetAssessmentInfo(
    GetStationAssessmentInfoEvent event,
    Emitter<AssessmentState> emit,
  ) async {

    final result = await assessmentRepository.getStationAssessmentInfo(event.stationId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: failure.message,
        ));
      },
      (infoEntity) {
        emit(state.copyWith(
          averageScore: infoEntity.averageScore,
          totalAssessments: infoEntity.totalAssessments,
        ));
      },
    );
  }
}