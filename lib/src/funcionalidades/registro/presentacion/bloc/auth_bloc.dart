import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  }

  Future<void> _onCheckEmailExistence(
    CheckEmailExistenceEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prevState = state;
    emit(AuthLoadingState());
    final result = await authRepository.isEmailRegistered(event.email);
    result.fold(
      (failure) {
        emit(
          AuthFailureState(
            errorCode: failure.message == 'invalid-email'
                ? failure.message!
                : _mapFailureToMessage(failure),
          ),
        );
        emit(prevState);
      },
      (isRegistered) =>
          emit(isRegistered ? EmailExistsState() : EmailIsNewState()),
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
    result.fold((failure) {
      emit(AuthFailureState(errorCode: _mapFailureToMessage(failure)));
      emit(prevState);
    }, (data) => emit(AuthSuccessState(
      meData: data['meData'] as Map<String, dynamic>?,
      firebaseUserId: data['firebaseUserId'] as String,
      firebaseToken: data['firebaseToken'] as String?,
    )));
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
        final needsToRegister = data['needsToRegister'] as bool;
        if (needsToRegister) {
          emit(GoogleUserIsNewState());
        } else {
          emit(AuthSuccessState(
            meData: data['meData'] as Map<String, dynamic>?,
            firebaseUserId: data['firebaseUserId'] as String,
            firebaseToken: data['firebaseToken'] as String?,
          ));
        }
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
