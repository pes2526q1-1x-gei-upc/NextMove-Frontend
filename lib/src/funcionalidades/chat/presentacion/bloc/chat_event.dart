import 'package:equatable/equatable.dart';
import '../../dominio/entities/message.dart';

/// Eventos del ChatBloc
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializar chat y conectar Socket.IO
class InitializeChat extends ChatEvent {
  final String firebaseToken;
  final String userId;

  const InitializeChat({
    required this.firebaseToken,
    required this.userId,
  });

  @override
  List<Object?> get props => [firebaseToken, userId];
}

/// Unirse a una sala de chat
class JoinChatRoom extends ChatEvent {
  final String roomId;

  const JoinChatRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Salir de una sala de chat
class LeaveChatRoom extends ChatEvent {
  final String roomId;

  const LeaveChatRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Enviar mensaje
class SendMessage extends ChatEvent {
  final String roomId;
  final String content;
  final String type;

  const SendMessage({
    required this.roomId,
    required this.content,
    this.type = 'text',
  });

  @override
  List<Object?> get props => [roomId, content, type];
}

/// Nuevo mensaje recibido (desde Socket.IO)
class MessageReceived extends ChatEvent {
  final Message message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

/// Usuario está escribiendo
class UserStartedTyping extends ChatEvent {
  final String roomId;
  final String userId;
  final String userName;

  const UserStartedTyping({
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [roomId, userId, userName];
}

/// Usuario dejó de escribir
class UserStoppedTyping extends ChatEvent {
  final String roomId;
  final String userId;

  const UserStoppedTyping({
    required this.roomId,
    required this.userId,
  });

  @override
  List<Object?> get props => [roomId, userId];
}

/// El usuario actual empieza a escribir
class StartTyping extends ChatEvent {
  final String roomId;

  const StartTyping(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// El usuario actual deja de escribir
class StopTyping extends ChatEvent {
  final String roomId;

  const StopTyping(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Usuario se unió a la sala
class UserJoinedRoom extends ChatEvent {
  final String roomId;
  final String userId;
  final String userName;

  const UserJoinedRoom({
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [roomId, userId, userName];
}

/// Usuario salió de la sala
class UserLeftRoom extends ChatEvent {
  final String roomId;
  final String userId;
  final String userName;

  const UserLeftRoom({
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [roomId, userId, userName];
}

/// Marcar mensaje como leído
class MarkMessageAsRead extends ChatEvent {
  final String messageId;
  final String roomId;

  const MarkMessageAsRead({
    required this.messageId,
    required this.roomId,
  });

  @override
  List<Object?> get props => [messageId, roomId];
}

/// Cargar historial de mensajes
class LoadMessageHistory extends ChatEvent {
  final String roomId;
  final int limit;

  const LoadMessageHistory({
    required this.roomId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [roomId, limit];
}

/// Desconectar del chat
class DisconnectChat extends ChatEvent {
  const DisconnectChat();
}

/// Error en el chat
class ChatError extends ChatEvent {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}