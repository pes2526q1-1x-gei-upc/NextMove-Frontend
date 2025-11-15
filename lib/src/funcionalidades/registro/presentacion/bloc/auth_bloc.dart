import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckEmailExistenceEvent>(_onCheckEmailExistence);
  }

  Future<void> _onCheckEmailExistence(
    CheckEmailExistenceEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    final result = await authRepository.isEmailRegistered(event.email);
    result.fold(
      (failure) => emit(
        AuthFailureState(
          errorCode: failure.message == 'invalid-email'
              ? failure.message!
              : _mapFailureToMessage(failure),
        ),
      ),
      (isRegistered) =>
          emit(isRegistered ? EmailExistsState() : EmailIsNewState()),
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
