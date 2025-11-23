import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserEntity user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUpdated extends UserState {
  final UserEntity user;

  const UserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserNeedsToSignUp extends UserState {}

class UserLoggedOut extends UserState {
  @override
  List<Object?> get props => [];
}