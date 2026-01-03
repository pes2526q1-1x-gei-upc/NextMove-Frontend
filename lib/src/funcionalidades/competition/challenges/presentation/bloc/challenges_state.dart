part of 'challenges_bloc.dart';

sealed class ChallengesState extends Equatable {
  const ChallengesState();

  @override
  List<Object> get props => [];
}

final class ChallengesInitial extends ChallengesState {}

final class ChallengesLoading extends ChallengesState {}

final class ChallengesLoaded extends ChallengesState {
  final List<Challenge> challenges;
  final EnrolledChallenge? enrolledChallenge;

  const ChallengesLoaded(this.challenges, {this.enrolledChallenge});

  bool get hasEnrolledChallenge => enrolledChallenge != null;

  @override
  List<Object> get props => [challenges, if (enrolledChallenge != null) enrolledChallenge!];
}

final class ChallengesError extends ChallengesState {
  final String message;

  const ChallengesError(this.message);

  @override
  List<Object> get props => [message];
}
