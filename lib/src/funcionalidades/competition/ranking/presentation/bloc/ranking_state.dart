part of 'ranking_bloc.dart';

sealed class RankingState extends Equatable {
  const RankingState();
  
  @override
  List<Object> get props => [];
}

final class RankingInitial extends RankingState {}

final class RankingLoading extends RankingState {}

final class RankingLoaded extends RankingState {
  final List<RankingEntry> rankingData;

  const RankingLoaded(this.rankingData);

  @override
  List<Object> get props => [rankingData];
}

final class RankingError extends RankingState {
  final String message;

  const RankingError(this.message);

  @override
  List<Object> get props => [message];
}