import 'package:bloc/bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository = UserRepository();

  UserBloc() : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<CreateUserProfile>(_onCreateUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await userRepository.getUserProfile(event.userId);
    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al cargar perfil')),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await userRepository.updateUserProfile(
      event.updatedUser,
      '',
    );
    //cuidao aqui el parametro vacio
    result.fold(
      (failure) =>
          emit(UserError(failure.message ?? 'Error al actualizar perfil')),
      (_) => emit(UserUpdated(event.updatedUser)),
    );
  }

   Future<void> _onCreateUserProfile(
    CreateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final result = await userRepository.createUserProfile(event.newUser);
    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al crear perfil')),
      (_) => emit(UserUpdated(event.newUser)),
    );
  } 
}
