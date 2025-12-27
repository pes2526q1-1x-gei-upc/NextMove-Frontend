import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/data/repositories/challenges_repository.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';

part 'challenges_event.dart';
part 'challenges_state.dart';

class ChallengesBloc extends Bloc<ChallengesEvent, ChallengesState> {
  final ChallengesRepository challengesRepository;
  ChallengesBloc()
    : challengesRepository = ChallengesRepository(),
      super(ChallengesInitial()) {
    on<LoadChallengeListEvent>(_onLoadChallengesEvent);
    on<EnrollInChallengeEvent>(_onEnrollInChallengeEvent);
  }

  Future<void> _onLoadChallengesEvent(
    LoadChallengeListEvent event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(ChallengesLoading());
    try {
      final result = await challengesRepository.getallChallenges();
      result.fold(
        (failure) =>
            emit(ChallengesError(failure.message ?? 'An error occurred')),
        (challenges) {
          emit(
            ChallengesLoaded(
              challenges ?? [],
              isEnrolled: challenges == null
                  ? false
                  : challenges.any((challenge) => challenge.isEnrolled),
            ),
          );
        },
      );
    } catch (e) {
      emit(ChallengesError('Failed to load challenges'));
    }
  }

  Future<void> _onEnrollInChallengeEvent(
    EnrollInChallengeEvent event,
    Emitter<ChallengesState> emit,
  ) async {
    if (state is ChallengesLoaded) {
      final currentState = state as ChallengesLoaded;
      try {
        await challengesRepository.enrollInChallenge(event.challengeId);
      } on Exception catch (e) {
        emit(ChallengesError('Failed to enroll in challenge: $e'));
        return;
      }
      final updatedChallenges = currentState.challenges.map((challenge) {
        if (challenge.id == event.challengeId) {
          final isEnrolled = challenge.isEnrolled;
          return challenge.copyWith(isEnrolled: !isEnrolled);
        }
        return challenge;
      }).toList();
      emit(ChallengesLoaded(updatedChallenges, isEnrolled: true));
    }
  }
}
