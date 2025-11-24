import 'package:equatable/equatable.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object?> get props => [];
}

// Carga inicial de la lista de amigos
class LoadFriendsEvent extends SocialEvent {
  final String currentUserId;
  const LoadFriendsEvent(this.currentUserId);
}

// Evento que se dispara al escribir en la barra de búsqueda
class SearchUsersEvent extends SocialEvent {
  final String query;
  const SearchUsersEvent(this.query);
}

// Limpiar búsqueda y volver a ver la lista de amigos
class ClearSearchEvent extends SocialEvent {}

// Acción de añadir amigo
class AddFriendEvent extends SocialEvent {
  final String currentUserId;
  final String friendId;
  const AddFriendEvent(this.currentUserId, this.friendId);
}