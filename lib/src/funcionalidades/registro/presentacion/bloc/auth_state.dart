part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class EmailIsNewState extends AuthState {}

final class EmailExistsState extends AuthState {}

final class GoogleUserIsNewState extends AuthState {}

final class GoogleUserExistsState extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthSuccessState extends AuthState {}

final class AuthFailureState extends AuthState {
  final String errorCode;

  const AuthFailureState({required this.errorCode});

  @override
  List<Object> get props => [errorCode];
}