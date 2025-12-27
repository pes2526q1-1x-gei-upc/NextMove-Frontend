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

final class EnrollInChallengeEvent extends ChallengesEvent {
  final String challengeId;

  const EnrollInChallengeEvent(this.challengeId);

  @override
  List<Object> get props => [challengeId];
}