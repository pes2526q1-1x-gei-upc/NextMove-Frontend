import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc() : authRepository = AuthRepository(), super(AuthInitial()) {
    on<CheckEmailExistenceEvent>(_onCheckEmailExistence);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onCheckEmailExistence(
    CheckEmailExistenceEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(AuthLoadingState());
    final result = await authRepository.isEmailRegisteredAndWithGoogle(
      event.email,
    );
    result.fold(
      (failure) {
        if (kDebugMode) {
          print('Error en isEmailRegisteredAndWithGoogle: ${failure.message}');
        }
        emit(
          AuthFailureState(
            errorCode: failure.message == 'invalid-email'
                ? failure.message!
                : _mapFailureToMessage(failure),
          ),
        );
        emit(prevState);
      },
      (data) {
        bool isEmailRegistered = data.value1;
        bool? isRegisteredWithGoogle = data.value2;
        if (isEmailRegistered) {
          if (isRegisteredWithGoogle == true) {
            emit(EmailExistsWithGoogleState());
          } else {
            emit(EmailExistsWithoutGoogleState());
          }
        } else {
          emit(EmailIsNewState());
        }
      },
    );
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(AuthLoadingState());
    final result = await authRepository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) {
        emit(AuthFailureState(errorCode: _mapFailureToMessage(failure)));
        emit(prevState);
      },
      (data) => emit(
        AuthSuccessState(
          meData: data['meData'] as Map<String, dynamic>?,
          firebaseUserId: data['firebaseUserId'] as String,
          firebaseToken: data['firebaseToken'] as String?,
        ),
      ),
    );
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(AuthLoadingState());
    final result = await authRepository.signUpWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    result.fold((failure) {
      emit(AuthFailureState(errorCode: _mapFailureToMessage(failure)));
      emit(prevState);
    }, (_) => emit(UserNeedsProfileSetupState()));
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(AuthLoadingState());
    final result = await authRepository.signInWithGoogle();
    result.fold(
      (failure) {
        emit(AuthFailureState(errorCode: _mapFailureToMessage(failure)));
        emit(prevState);
      },
      (data) {
        if (data['cancelled'] == true) {
          if (kDebugMode) {
            print('Inici de sessió amb Google cancel·lat per l\'usuari.');
          }
          emit(prevState);
          return;
        }
        final needsToRegister = data['needsToRegister'] as bool;
        if (kDebugMode) {
          print("needsToRegister: $needsToRegister");
        }
        if (needsToRegister) {
          emit(UserNeedsProfileSetupState());
        } else {
          emit(
            AuthSuccessState(
              meData: data['meData'] as Map<String, dynamic>?,
              firebaseUserId: data['firebaseUserId'] as String,
              firebaseToken: data['firebaseToken'] as String?,
            ),
          );
        }
      },
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(AuthLoadingState());
    final result = await authRepository.deleteAccount(event.password);
    result.fold(
      (failure) {
        emit(AuthFailureState(errorCode: _mapFailureToMessage(failure)));
        emit(prevState);
      },
      (_) {
        emit(AccountDeletedState());
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure.message != null && failure.message!.isNotEmpty) {
      return failure.message!;
    }
    if (failure is ConnectionFailure) {
      return 'connection-error';
    }
    if (failure is ServerFailure) {
      return 'server-error';
    }
    if (failure is AuthFailure) {
      return 'auth-error';
    }
    return 'unknown-error';
  }
}
