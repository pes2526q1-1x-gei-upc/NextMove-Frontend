import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/data/repositories/social_repository.dart';
import 'social_event.dart';
import 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialRepository socialRepository;

  String? _currentNickname;

  SocialBloc({SocialRepository? socialRepository})
      : socialRepository = socialRepository ?? SocialRepository(),
        super(const SocialState()) {
    on<LoadFriendsEvent>(_onLoadFriends);
    on<SearchUsersEvent>(_onSearchUsers);
    on<ClearSearchEvent>(_onClearSearch);
    on<AddFriendEvent>(_onAddFriend);
    on<DeleteFriendEvent>(_onDeleteFriend);
    on<BlockUserEvent>(_onBlockUser);
    on<LoadBlockedUsersEvent>(_onLoadBlockedUsers);
    on<UnblockUserEvent>(_onUnblockUser);
  }

  Future<void> _onLoadFriends(
    LoadFriendsEvent event,
    Emitter<SocialState> emit,
  ) async {
    _currentNickname = event.currentUserId;
    emit(state.copyWith(status: SocialStatus.loading));

    final result = await socialRepository.getFriends();

    result.fold(
      (failure) => emit(state.copyWith(
        status: SocialStatus.failure,
        errorMessage: failure.message,
      )),
      (friends) => emit(state.copyWith(
        status: SocialStatus.success,
        friends: friends,
      )),
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<SocialState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(ClearSearchEvent());
      return;
    }

    emit(state.copyWith(status: SocialStatus.loading, isSearching: true));

    final result = await socialRepository.searchUsers(event.query);

    result.fold(
      (failure) => emit(state.copyWith(
        status: SocialStatus.failure,
        errorMessage: failure.message,
      )),
      (users) {
        // Filtramos al propio usuario de los resultados de búsqueda
        final filteredUsers = users
            .where((u) => u.apodo != _currentNickname)
            .toList();

        emit(state.copyWith(
          status: SocialStatus.success,
          searchResults: filteredUsers,
          isSearching: true,
        ));
      },
    );
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SocialState> emit) {
    emit(state.copyWith(
      isSearching: false,
      searchResults: [],
      status: SocialStatus.success,
    ));
  }

  Future<void> _onAddFriend(
    AddFriendEvent event,
    Emitter<SocialState> emit,
  ) async {
    _currentNickname = event.currentUserId;
    if (_currentNickname == null) return;

    final result = await socialRepository.addFriend(event.friendId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Fallo al añadir: ${failure.message}")),
      (_) {
        // Actualizamos la lista de amigos tras la adición exitosa
        add(LoadFriendsEvent(_currentNickname!));
        add(ClearSearchEvent());
      },
    );
  }

  Future<void> _onDeleteFriend(
    DeleteFriendEvent event,
    Emitter<SocialState> emit,
  ) async {
    _currentNickname = event.currentUserId;
    if (_currentNickname == null) return;

    final result = await socialRepository.removeFriend(event.friendId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Fallo al eliminar: ${failure.message}")),
      (_) {
        add(LoadFriendsEvent(_currentNickname!));
        add(ClearSearchEvent());
      },
    );
  }

  Future<void> _onBlockUser(
    BlockUserEvent event,
    Emitter<SocialState> emit,
  ) async {
    _currentNickname = event.currentUserId;
    
    final result = await socialRepository.blockUser(event.userToBlockId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Fallo al bloquear: ${failure.message}")),
      (_) {
        if (_currentNickname != null) {
          add(LoadFriendsEvent(_currentNickname!));
        }
        add(ClearSearchEvent());
      },
    );
  }

  Future<void> _onLoadBlockedUsers(
    LoadBlockedUsersEvent event,
    Emitter<SocialState> emit,
  ) async {
    emit(state.copyWith(status: SocialStatus.loading));

    final result = await socialRepository.getBlockedUsers();

    result.fold(
      (failure) => emit(state.copyWith(
        status: SocialStatus.failure,
        errorMessage: failure.message,
      )),
      (blockedUsers) => emit(state.copyWith(
        status: SocialStatus.success,
        blockedUsers: blockedUsers,
      )),
    );
  }

  Future<void> _onUnblockUser(
    UnblockUserEvent event,
    Emitter<SocialState> emit,
  ) async {
    final result = await socialRepository.unblockUser(event.userToUnblockId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Fallo al desbloquear: ${failure.message}")),
      (_) => add(LoadBlockedUsersEvent()),
    );
  }
}
