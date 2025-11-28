part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class EmailIsNewState extends AuthState {}

final class EmailExistsWithoutGoogleState extends AuthState {}

final class EmailExistsWithGoogleState extends AuthState {}

final class GoogleUserIsNewState extends AuthState {}

final class GoogleUserExistsState extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class UserNeedsProfileSetupState extends AuthState {}

final class AuthSuccessState extends AuthState {
  final Map<String, dynamic>? meData;
  final String firebaseUserId;
  final String? firebaseToken;

  const AuthSuccessState({
    required this.meData,
    required this.firebaseUserId,
    required this.firebaseToken,
  });

  @override
  List<Object> get props => [meData ?? {}, firebaseUserId, firebaseToken ?? ''];
}

final class AuthFailureState extends AuthState {
  final String errorCode;

  const AuthFailureState({required this.errorCode});

  @override
  List<Object> get props => [errorCode];
}