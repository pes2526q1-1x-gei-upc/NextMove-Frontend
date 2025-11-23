import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/data/repositories/social_repository.dart';
import 'social_event.dart';
import 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialRepository socialRepository = SocialRepository();
  
  // Guardamos el nickname actual para usarlo en operaciones de añadir/borrar
  String? _currentNickname;

  SocialBloc() : super(const SocialState()) {
    on<LoadFriendsEvent>(_onLoadFriends);
    on<SearchUsersEvent>(_onSearchUsers);
    on<ClearSearchEvent>(_onClearSearch);
    on<AddFriendEvent>(_onAddFriend);
  }

  Future<void> _onLoadFriends(LoadFriendsEvent event, Emitter<SocialState> emit) async {
    _currentNickname = event.currentUserId;
    debugPrint("[SocialBloc] Cargando amigos para: $_currentNickname");
    
    emit(state.copyWith(status: SocialStatus.loading));
    
    // LLAMADA REAL AL REPOSITORIO
    final result = await socialRepository.getFriends(_currentNickname!);
    
    result.fold(
      (failure) {
        debugPrint("[SocialBloc] Falló carga de amigos: ${failure.message}");
        emit(state.copyWith(
          status: SocialStatus.failure, 
          errorMessage: failure.message
        ));
      },
      (friends) {
        debugPrint("[SocialBloc] Amigos cargados: ${friends.length}");
        emit(state.copyWith(
          status: SocialStatus.success, 
          friends: friends
        ));
      },
    );
  }

  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<SocialState> emit) async {
    // Si el campo está vacío, limpiamos
    if (event.query.isEmpty) {
      add(ClearSearchEvent());
      return;
    }

    debugPrint("[SocialBloc] Buscando: '${event.query}'");
    emit(state.copyWith(status: SocialStatus.loading, isSearching: true));
    
    // LLAMADA REAL AL REPOSITORIO (Busca por email ahora)
    final result = await socialRepository.searchUsers(event.query);

    result.fold(
      (failure) {
        debugPrint("[SocialBloc] Error buscando: ${failure.message}");
        emit(state.copyWith(
          status: SocialStatus.failure, 
          errorMessage: failure.message
        ));
      },
      (users) {
        debugPrint("[SocialBloc] Resultados encontrados: ${users.length}");
        
        // Filtramos para no mostrarnos a nosotros mismos si buscamos nuestro propio email
        // (Asumiendo que _currentNickname tiene el apodo, comparamos apodos si están disponibles)
        final filteredUsers = users.where((u) => u.apodo != _currentNickname).toList();
        
        emit(state.copyWith(
          status: SocialStatus.success, 
          searchResults: filteredUsers,
          isSearching: true
        ));
      },
    );
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SocialState> emit) {
    debugPrint("[SocialBloc] Limpiando búsqueda");
    emit(state.copyWith(isSearching: false, searchResults: [], status: SocialStatus.success));
  }

  Future<void> _onAddFriend(AddFriendEvent event, Emitter<SocialState> emit) async {
    if (_currentNickname == null) {
      debugPrint("[SocialBloc] No se puede añadir amigo: _currentNickname es null");
      return;
    }

    debugPrint("[SocialBloc] Solicitando amistad a: ${event.friendId}");

    final result = await socialRepository.addFriend(_currentNickname!, event.friendId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Error al añadir: ${failure.message}")),
      (_) {
        debugPrint("[SocialBloc] Amigo añadido con éxito");
        // Recargamos la lista de amigos para que aparezca el nuevo
        add(LoadFriendsEvent(_currentNickname!));
        // Limpiamos la búsqueda para volver a la lista principal
        add(ClearSearchEvent());
      },
    );
  }
}