part of 'challenges_bloc.dart';

sealed class ChallengesEvent extends Equatable {
  const ChallengesEvent();

  @override
  List<Object> get props => [];
}

final class LoadChallengeListEvent extends ChallengesEvent {
  const LoadChallengeListEvent();

  @override
  List<Object> get props => [];
}

final class LoadChallengeDetailsEvent extends ChallengesEvent {
  final String challengeName;

  const LoadChallengeDetailsEvent(this.challengeName);

  @override
  List<Object> get props => [challengeName];
}