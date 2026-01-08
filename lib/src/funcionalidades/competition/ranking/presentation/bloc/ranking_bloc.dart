import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/data/repositories/ranking_repository.dart';
import 'package:nextmove_app/src/funcionalidades/competition/ranking/domain/ranking_entry.dart';

part 'ranking_event.dart';
part 'ranking_state.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final RankingRepository rankingRepository;

  RankingBloc()
    : rankingRepository = RankingRepository(),
      super(RankingInitial()) {
    on<LoadRankingEvent>(_onLoadRankingEvent);
  }

  Future<void> _onLoadRankingEvent(
    LoadRankingEvent event,
    Emitter<RankingState> emit,
  ) async {
    emit(RankingLoading());
    final result = await rankingRepository.getRankingData(event.metric);
    result.fold(
      (failure) => emit(RankingError(failure.message ?? 'An error occurred')),
      (rankingData) => emit(RankingLoaded(rankingData ?? [])),
    );
  }
}
