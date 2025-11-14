import 'package:bloc/bloc.dart';
import '../../../domain/usecases/get_user_profile_use_case.dart';
import '../../../domain/usecases/update_user_profile_use_case.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  UserBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
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
    final result = await updateUserProfileUseCase(event.updatedUser, '');  // UserId no necesario si auth maneja
    result.fold(
      (failure) => emit(UserError(failure.message ?? 'Error al actualizar perfil')),
      (_) => emit(UserUpdated(event.updatedUser)),
    );
  }
}