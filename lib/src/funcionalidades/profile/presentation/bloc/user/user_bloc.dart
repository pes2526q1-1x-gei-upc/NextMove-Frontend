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
    on<LogoutUser>(_onLogoutUser);
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
    final result = await userRepository.updateUserProfile(event.updatedUser,);
    result.fold(
      (failure) =>
          emit(UserError(failure.message ?? 'Error al actualizar perfil')),
      (updatedUser) => emit(UserUpdated(updatedUser)),
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
      (createdUser) => emit(UserUpdated(createdUser)),
    );
  } 


  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading()); // Para mostrar spinner si es necesario
    
    final result = await userRepository.logoutUser();
    
    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al cerrar sesión')),
      (_) => emit(UserLoggedOut()), // Éxito
    );
  }
}
