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
  }

  Future<void> _onLoadChallengesEvent(
    LoadChallengeListEvent event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(ChallengesLoading());
    try {
      final result = await challengesRepository.getallChallenges();
      result.fold(
        (failure) => emit(ChallengesError(failure.message ?? 'An error occurred')),
        (challenges) => emit(ChallengesLoaded(challenges ?? [])),
      );
    } catch (e) {
      emit(ChallengesError('Failed to load challenges'));
    }
  }
}
