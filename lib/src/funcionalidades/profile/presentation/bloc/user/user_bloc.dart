import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:bloc/bloc.dart';
import 'package:nextmove_app/main.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/datasources/user_remote_data_source.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/usecases/create_user_profile_use_case.dart';
import 'package:provider/provider.dart';
import '../../../domain/usecases/get_user_profile_use_case.dart';
import '../../../domain/usecases/update_user_profile_use_case.dart';
import 'user_event.dart';
import 'user_state.dart';


class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  //final UserRepositoryImpl userRepository = UserRepositoryImpl(remoteDataSource: UserRemoteDataSource(graphQLClient: , firebaseAuth: firebaseAuth), localDataSource: localDataSource);
  //final CreateUserProfileUseCase createUserProfileUseCase;

  UserBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    //required this.createUserProfileUseCase,
  }) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    //on<CreateUserProfile>(_onCreateUserProfile);
  }

  Future<void> _onLoadUserProfile(LoadUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final result = await getUserProfileUseCase(event.userId);
    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al cargar perfil')),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> _onUpdateUserProfile(UpdateUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());

    final result = await updateUserProfileUseCase(event.updatedUser, '').call(); //cuidao aqui el parametro vacio
    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al actualizar perfil')),
      (_) => emit(UserUpdated(event.updatedUser)),
    );
  }
/*
  Future<void> _onCreateUserProfile(CreateUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    String? pwd = userProvider.pwd;
    
    final result = await createUserProfileUseCase(event.newUser, pwd!).call(); //cuidao aqui el parametro vacio
    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al crear perfil')),
      (_) => emit(UserUpdated(event.newUser)),
    );
  } */
}