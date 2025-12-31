part of 'ranking_bloc.dart';

sealed class RankingEvent extends Equatable {
  const RankingEvent();

  @override
  List<Object> get props => [];
}

final class LoadRankingEvent extends RankingEvent {
  final String metric;

  const LoadRankingEvent(this.metric);

  @override
  List<Object> get props => [metric];
}
