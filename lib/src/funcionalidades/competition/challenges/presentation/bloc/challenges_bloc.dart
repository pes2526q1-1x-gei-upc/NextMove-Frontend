import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/data/repositories/challenges_repository.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/enrolled_challenge.dart';

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
      final enrolledChallengeResult = await challengesRepository.getEnrolledChallenge();
      
      EnrolledChallenge? enrolledChallenge;
      enrolledChallengeResult.fold(
        (failure) => null,
        (enrolledChallengeFromQuery) {
          enrolledChallenge = enrolledChallengeFromQuery;
        },
      );
      
      result.fold(
        (failure) =>
            emit(ChallengesError(failure.message ?? 'An error occurred')),
        (challenges) {
          emit(
            ChallengesLoaded(
              challenges ?? [],
              enrolledChallenge: enrolledChallenge,
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
        
        final enrolledChallenge = currentState.challenges
            .where((challenge) => challenge.id == event.challengeId)
            .map((challenge) => EnrolledChallenge(
              id: challenge.id,
              name: challenge.name,
              company: challenge.company,
              description: challenge.description,
              distance: challenge.distance,
              points: challenge.points,
              startingDate: challenge.startingDate,
              endingDate: challenge.endingDate,
              photo: challenge.photo,
              isCompleted: challenge.isCompleted,
              completed: 0,
              totalDistance: challenge.distance,
              currentDistance: 0.0,
            ))
            .firstOrNull;

        emit(ChallengesLoaded(currentState.challenges, enrolledChallenge: enrolledChallenge));
        if (kDebugMode) {
          print("ChallengesBloc: Enrolled in challenge ${event.challengeId}. State's current enrolled challenge: ${currentState.enrolledChallenge?.id}");
        }
      } on Exception catch (e) {
        emit(ChallengesError('Failed to enroll in challenge: $e'));
        return;
      }
    }
  }
}
