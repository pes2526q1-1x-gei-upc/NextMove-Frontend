import 'package:equatable/equatable.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';

enum SocialStatus { initial, loading, success, failure }

class SocialState extends Equatable {
  final SocialStatus status;
  final List<UserEntity> friends;       // Lista de amigos actuales
  final List<UserEntity> searchResults; // Resultados de la búsqueda
  final bool isSearching;               // ¿Está el usuario buscando activamente?
  final String? errorMessage;

  const SocialState({
    this.status = SocialStatus.initial,
    this.friends = const [],
    this.searchResults = const [],
    this.isSearching = false,
    this.errorMessage,
  });

  SocialState copyWith({
    SocialStatus? status,
    List<UserEntity>? friends,
    List<UserEntity>? searchResults,
    bool? isSearching,
    String? errorMessage,
  }) {
    return SocialState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, friends, searchResults, isSearching, errorMessage];
}