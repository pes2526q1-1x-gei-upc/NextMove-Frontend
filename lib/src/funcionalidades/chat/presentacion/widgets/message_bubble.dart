import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dominio/entities/message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showSender;
  final VoidCallback? onAvatarTap;
  final bool isGroup; // Indica si es un chat de grupo

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSender = true,
    this.onAvatarTap,
    this.isGroup = false,
  });

  void _showDeleteConfirmation(BuildContext context, ChatBloc chatBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar mensaje'),
        content: const Text('¿Estás seguro de que quieres eliminar este mensaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              chatBloc.add(DeleteMessage(
                messageId: message.id,
                roomId: message.roomId,
              ));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ChatBloc chatBloc) {
    final TextEditingController editController = TextEditingController(text: message.content);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar mensaje'),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Escribe tu mensaje...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty && newContent != message.content) {
                chatBloc.add(EditMessage(
                  messageId: message.id,
                  roomId: message.roomId,
                  newContent: newContent,
                ));
                Navigator.pop(dialogContext);
              } else if (newContent.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El mensaje no puede estar vacío')),
                );
              } else {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Obtener el ChatBloc antes de mostrar el BottomSheet
    final chatBloc = context.read<ChatBloc>();
    
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: chatBloc,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.delete),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteConfirmation(context, chatBloc);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showEditDialog(context, chatBloc);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    
    // Mostrar avatar solo en grupos y cuando el mensaje no es del usuario actual
    final shouldShowAvatar = isGroup && !isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del remitente (solo en grupos y para mensajes de otros)
          if (shouldShowAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: message.senderPhoto != null && message.senderPhoto!.isNotEmpty
                      ? NetworkImage(message.senderPhoto!)
                      : null,
                  child: message.senderPhoto == null || message.senderPhoto!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        )
                      : null,
                ),
              ),
            ),
          Flexible(
            child: GestureDetector(
              onLongPress: isMe && !message.deleted
                  ? () => _showMessageOptions(context)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: message.edited && !message.deleted
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del remitente en grupos
                          if (shouldShowAvatar && showSender)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                message.senderName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          Text(
                            message.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isMe
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '(editado)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 9,
                                  color: isMe
                                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.6)
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                timeFormat.format(message.timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: isMe
                                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del remitente en grupos
                          if (shouldShowAvatar && showSender)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                message.senderName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  message.deleted
                                      ? 'Mensaje eliminado'
                                      : message.content,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isMe
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                    fontStyle: message.deleted
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeFormat.format(message.timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: isMe
                                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}