import 'package:equatable/equatable.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object?> get props => [];
}

// Inicializa la carga de amigos del usuario actual
class LoadFriendsEvent extends SocialEvent {
  final String currentUserId;
  const LoadFriendsEvent(this.currentUserId);
}

// Ejecuta la búsqueda de usuarios por apodo
class SearchUsersEvent extends SocialEvent {
  final String query;
  const SearchUsersEvent(this.query);
}

// Limpia los resultados y el estado de búsqueda
class ClearSearchEvent extends SocialEvent {}

class AddFriendEvent extends SocialEvent {
  final String currentUserId;
  final String friendId;
  const AddFriendEvent(this.currentUserId, this.friendId);
}

class DeleteFriendEvent extends SocialEvent {
  final String currentUserId;
  final String friendId;
  const DeleteFriendEvent(this.currentUserId, this.friendId);
}

class BlockUserEvent extends SocialEvent {
  final String currentUserId; 
  final String userToBlockId; 
  
  const BlockUserEvent(this.currentUserId, this.userToBlockId);
}

class LoadBlockedUsersEvent extends SocialEvent {}

class UnblockUserEvent extends SocialEvent {
  final String userToUnblockId;
  const UnblockUserEvent(this.userToUnblockId);
}
