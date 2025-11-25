import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/data/repositories/social_repository.dart';
import 'social_event.dart';
import 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialRepository socialRepository = SocialRepository();

  String? _currentNickname;

  SocialBloc() : super(const SocialState()) {
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
    debugPrint("[SocialBloc] Cargando amigos para: $_currentNickname");

    emit(state.copyWith(status: SocialStatus.loading));

    final result = await socialRepository.getFriends();

    result.fold(
      (failure) {
        debugPrint("[SocialBloc] Falló carga de amigos: ${failure.message}");
        emit(
          state.copyWith(
            status: SocialStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (friends) {
        debugPrint("[SocialBloc] Amigos cargados: ${friends.length}");
        debugPrint(
          "SocialBloc: Loaded friends: ${friends.map((f) => f.apodo).toList()}",
        );
        emit(state.copyWith(status: SocialStatus.success, friends: friends));
      },
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

    debugPrint("[SocialBloc] Buscando: '${event.query}'");
    emit(state.copyWith(status: SocialStatus.loading, isSearching: true));

    final result = await socialRepository.searchUsers(event.query);

    result.fold(
      (failure) {
        debugPrint("[SocialBloc] Error buscando: ${failure.message}");
        emit(
          state.copyWith(
            status: SocialStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (users) {
        debugPrint("[SocialBloc] Resultados encontrados: ${users.length}");

        // Filtramos para no mostrarnos a nosotros mismos
        final filteredUsers = users
            .where((u) => u.apodo != _currentNickname)
            .toList();

        emit(
          state.copyWith(
            status: SocialStatus.success,
            searchResults: filteredUsers,
            isSearching: true,
          ),
        );
      },
    );
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SocialState> emit) {
    debugPrint("[SocialBloc] Limpiando búsqueda");
    emit(
      state.copyWith(
        isSearching: false,
        searchResults: [],
        status: SocialStatus.success,
      ),
    );
  }

  Future<void> _onAddFriend(
    AddFriendEvent event,
    Emitter<SocialState> emit,
  ) async {
    _currentNickname = event.currentUserId;
    if (_currentNickname == null) {
      debugPrint(
        "[SocialBloc] No se puede añadir amigo: _currentNickname es null",
      );
      return;
    }

    debugPrint("[SocialBloc] Solicitando amistad a: ${event.friendId}");

    final result = await socialRepository.addFriend(event.friendId);

    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: "Error al añadir: ${failure.message}"),
      ),
      (_) {
        debugPrint("[SocialBloc] Amigo añadido con éxito");
        // Recargamos la lista de amigos para que aparezca el nuevo
        add(LoadFriendsEvent(_currentNickname!));
        // Limpiamos la búsqueda para volver a la lista principal
        add(ClearSearchEvent());
      },
    );
  }

  Future<void> _onDeleteFriend(
    DeleteFriendEvent event,
    Emitter<SocialState> emit,
  ) async {
    _currentNickname = event.currentUserId;
    if (_currentNickname == null) {
      debugPrint(
        "[SocialBloc] No se puede eliminar amigo: _currentNickname es null",
      );
      return;
    }

    debugPrint(
      "[SocialBloc] Solicitando eliminación de amistad a: ${event.friendId}",
    );

    final result = await socialRepository.removeFriend(event.friendId);

    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: "Error al eliminar: ${failure.message}"),
      ),
      (_) {
        debugPrint("[SocialBloc] Amigo eliminado con éxito");
        // Recargamos la lista de amigos para que se refleje la eliminación
        add(LoadFriendsEvent(_currentNickname!));
        // Limpiamos la búsqueda para volver a la lista principal
        add(ClearSearchEvent());
      },
    );
  }

  Future<void> _onBlockUser(
    BlockUserEvent event,
    Emitter<SocialState> emit,
  ) async {
    _currentNickname = event.currentUserId;
    debugPrint("[SocialBloc] Bloqueando a: ${event.userToBlockId}");

    final result = await socialRepository.blockUser(event.userToBlockId);

    result.fold(
      (failure) {
        debugPrint("[SocialBloc] Error al bloquear: ${failure.message}");
        emit(
          state.copyWith(errorMessage: "Error al bloquear: ${failure.message}"),
        );
      },
      (_) {
        debugPrint("[SocialBloc] Usuario bloqueado con éxito");

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
    debugPrint("[SocialBloc] Cargando usuarios bloqueados");
    emit(state.copyWith(status: SocialStatus.loading));

    final result = await socialRepository.getBlockedUsers();

    result.fold(
      (failure) {
        debugPrint(
          "[SocialBloc] Error cargando bloqueados: ${failure.message}",
        );
        emit(
          state.copyWith(
            status: SocialStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (blockedUsers) {
        debugPrint("[SocialBloc] Bloqueados cargados: ${blockedUsers.length}");
        emit(
          state.copyWith(
            status: SocialStatus.success,
            blockedUsers: blockedUsers,
          ),
        );
      },
    );
  }

  Future<void> _onUnblockUser(
    UnblockUserEvent event,
    Emitter<SocialState> emit,
  ) async {
    debugPrint("[SocialBloc] Desbloqueando a: ${event.userToUnblockId}");

    final result = await socialRepository.unblockUser(event.userToUnblockId);

    result.fold(
      (failure) {
        debugPrint("[SocialBloc] Error al desbloquear: ${failure.message}");
        emit(
          state.copyWith(
            errorMessage: "Error al desbloquear: ${failure.message}",
          ),
        );
      },
      (_) {
        debugPrint("[SocialBloc] Usuario desbloqueado con éxito");
        // Recargar la lista de bloqueados
        add(LoadBlockedUsersEvent());
      },
    );
  }
}
