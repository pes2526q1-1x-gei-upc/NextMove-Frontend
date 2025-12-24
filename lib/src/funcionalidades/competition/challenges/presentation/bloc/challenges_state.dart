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

  const ChallengesLoaded(this.challenges);

  @override
  List<Object> get props => [challenges];
}

final class ChallengesError extends ChallengesState {
  final String message;

  const ChallengesError(this.message);

  @override
  List<Object> get props => [message];
}