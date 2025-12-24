part of 'challenges_bloc.dart';

sealed class ChallengesEvent extends Equatable {
  const ChallengesEvent();

  @override
  List<Object> get props => [];
}

final class LoadChallengesEvent extends ChallengesEvent {
  const LoadChallengesEvent();

  @override
  List<Object> get props => [];
}
