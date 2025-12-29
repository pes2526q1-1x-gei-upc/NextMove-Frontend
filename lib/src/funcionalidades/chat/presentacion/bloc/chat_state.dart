import 'package:equatable/equatable.dart';
import '../../dominio/entities/message.dart';

/// Estados del ChatBloc
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Conectando al servidor de chat
class ChatConnecting extends ChatState {
  const ChatConnecting();
}

/// Conectado al servidor de chat
class ChatConnected extends ChatState {
  final String userId;

  const ChatConnected(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Error de conexión
class ChatConnectionError extends ChatState {
  final String message;

  const ChatConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Desconectado del servidor
class ChatDisconnected extends ChatState {
  const ChatDisconnected();
}

/// Estado de una sala de chat activa
class ChatRoomActive extends ChatState {
  final String roomId;
  final List<Message> messages;
  final Set<String> usersTyping;
  final int userCount;
  final bool isLoadingHistory;

  const ChatRoomActive({
    required this.roomId,
    required this.messages,
    this.usersTyping = const {},
    this.userCount = 0,
    this.isLoadingHistory = false,
  });

  ChatRoomActive copyWith({
    String? roomId,
    List<Message>? messages,
    Set<String>? usersTyping,
    int? userCount,
    bool? isLoadingHistory,
  }) {
    return ChatRoomActive(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      usersTyping: usersTyping ?? this.usersTyping,
      userCount: userCount ?? this.userCount,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }

  @override
  List<Object?> get props => [
        roomId,
        messages,
        usersTyping,
        userCount,
        isLoadingHistory,
      ];
}

/// Error en una sala de chat
class ChatRoomError extends ChatState {
  final String roomId;
  final String message;

  const ChatRoomError({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object?> get props => [roomId, message];
}

/// Mensaje enviado exitosamente
class MessageSent extends ChatState {
  final String roomId;
  final String messageId;

  const MessageSent({
    required this.roomId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [roomId, messageId];
}

/// Enviando mensaje
class SendingMessage extends ChatState {
  final String roomId;
  final String content;

  const SendingMessage({
    required this.roomId,
    required this.content,
  });

  @override
  List<Object?> get props => [roomId, content];
}

/// Participante expulsado de grupo (para notificar a la UI)
class GroupParticipantKickedState extends ChatState {
  final String chatId;
  final String chatName;

  const GroupParticipantKickedState({
    required this.chatId,
    required this.chatName,
  });

  @override
  List<Object?> get props => [chatId, chatName];
}

/// Usuario expulsado de grupo (para notificar a la UI)
class UserKickedFromGroupState extends ChatState {
  final String chatId;
  final String chatName;
  const UserKickedFromGroupState({required this.chatId, required this.chatName});
  @override
  List<Object?> get props => [chatId, chatName];
}

/// Usuario añadido a grupo (para notificar a la UI)
class GroupUserAddedState extends ChatState {
  final String chatId;
  final String chatName;
  const GroupUserAddedState({required this.chatId, required this.chatName});
  @override
  List<Object?> get props => [chatId, chatName];
}

/// Grupo eliminado
class GroupDeletedState extends ChatState {
  final String chatId;
  final String chatName;
  const GroupDeletedState({required this.chatId, required this.chatName});
  @override
  List<Object?> get props => [chatId, chatName];
}