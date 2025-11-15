part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class CheckEmailExistenceEvent extends AuthEvent {
  final String email;

  const CheckEmailExistenceEvent({required this.email});

  @override
  List<Object> get props => [email];
}

final class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailEvent(
      {required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();

  @override
  List<Object> get props => [];
}