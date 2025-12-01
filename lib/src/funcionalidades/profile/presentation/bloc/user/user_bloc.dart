import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
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
    print("UserBloc: Loading profile for ${event.userId}");
    emit(UserLoading());
    final result = await userRepository.getUserProfile(event.userId);
    result.fold(
      (failure) {
        print("UserBloc: Failed to load profile: ${failure.message}");
        emit(UserNeedsToSignUp());
      },
      (user) {
        print(
          "UserBloc: Loaded profile for ${user.apodo} (Email: ${user.email})",
        );
        emit(UserLoaded(user));
      },
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    debugPrint(
      "UserBloc: Received UpdateUserProfile event for ${event.updatedUser.apodo}",
    );
    emit(UserLoading());

    // 1. Upload photo if present
    if (event.profilePhoto != null) {
      debugPrint("UserBloc: Uploading profile photo...");
      final uploadResult = await userRepository.uploadProfilePhoto(
        event.profilePhoto!,
      );

      final failureOrUrl = uploadResult.fold((l) => l, (r) => r);
      if (failureOrUrl is Failure) {
        // Check if it's a failure
        debugPrint("UserBloc: Photo upload failed: ${failureOrUrl.message}");
        emit(UserError(failureOrUrl.message ?? 'Error al subir foto'));
        return;
      }
      debugPrint("UserBloc: Photo uploaded successfully. URL: $failureOrUrl");
      // We don't need to update event.updatedUser.photo because the backend handles it,
      // and the subsequent updateProfile call will return the fresh user object.
    }

    debugPrint("UserBloc: Calling userRepository.updateUserProfile...");
    final result = await userRepository.updateUserProfile(event.updatedUser);
    result.fold(
      (failure) {
        debugPrint("UserBloc: Update failed with error: ${failure.message}");
        emit(UserError(failure.message ?? 'Error al actualizar perfil'));
      },
      (updatedUser) {
        debugPrint("UserBloc: Update successful. Emitting UserUpdated state.");
        emit(UserUpdated(updatedUser));
      },
    );
  }

  Future<void> _onCreateUserProfile(
    CreateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    debugPrint(
      "UserBloc: Received CreateUserProfile event for ${event.newUser.email}",
    );
    emit(UserLoading());
    debugPrint("UserBloc: Emitted UserLoading state");

    debugPrint("UserBloc: Calling userRepository.createUserProfile...");
    final result = await userRepository.createUserProfile(event.newUser);
    result.fold(
      (failure) {
        debugPrint("UserBloc: Create failed with error: ${failure.message}");
        emit(UserError(failure.message ?? 'Error al crear perfil'));
      },
      (createdUser) {
        debugPrint("UserBloc: Create successful. Emitting UserUpdated state.");
        emit(UserUpdated(createdUser));
      },
    );
  }

  Future<void> _onLogoutUser(LogoutUser event, Emitter<UserState> emit) async {
    emit(UserLoading()); // Para mostrar spinner si es necesario

    final result = await userRepository.logoutUser();

    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al cerrar sesión')),
      (_) => emit(UserLoggedOut()), // Éxito
    );
  }
}
