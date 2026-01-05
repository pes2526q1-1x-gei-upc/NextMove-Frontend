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
  final Map<String, String>? participantsMap; // Mapa de email -> nickname
  final bool showAvatar; // Mostrar avatar (último mensaje del grupo)
  final bool showSenderName; // Mostrar nombre (primer mensaje del grupo)
  final Function(Message)? onEditMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSender = true,
    this.onAvatarTap,
    this.isGroup = false,
    this.participantsMap,
    this.showAvatar = true, // Por defecto mostrar avatar
    this.showSenderName = true, // Por defecto mostrar nombre
    this.onEditMessage,
  });

  void _showDeleteConfirmation(BuildContext context, ChatBloc chatBloc) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(l10n.deleteMessage),
          ],
        ),
        content: Text(l10n.areYouSureDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              chatBloc.add(
                DeleteMessage(messageId: message.id, roomId: message.roomId),
              );
              Navigator.pop(dialogContext);

              // Mostrar SnackBar con confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.messageDeleted),
                    ],
                  ),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(
              l10n.delete,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Obtener el ChatBloc antes de mostrar el BottomSheet
    final chatBloc = context.read<ChatBloc>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => BlocProvider.value(
        value: chatBloc,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n.edit),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  onEditMessage?.call(message);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  l10n.delete,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteConfirmation(context, chatBloc);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getSenderDisplayName() {
    String displayName = message.senderName;


    if (displayName.contains('@')) {
      if (participantsMap != null &&
          participantsMap!.containsKey(displayName)) {
        return participantsMap![displayName]!;
      }

      if (participantsMap != null &&
          message.senderId.contains('@') &&
          participantsMap!.containsKey(message.senderId)) {
        return participantsMap![message.senderId]!;
      }

      return displayName.split('@').first;
    }
    if (message.senderId.contains('@') &&
        participantsMap != null &&
        participantsMap!.containsKey(message.senderId)) {
      return participantsMap![message.senderId]!;
    }

    return displayName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat('HH:mm');
    final senderDisplayName = _getSenderDisplayName();

    // Mostrar avatar solo en grupos, cuando el mensaje no es del usuario actual, y cuando showAvatar es true
    final shouldShowAvatar = isGroup && !isMe && showAvatar;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del remitente (solo en grupos y para mensajes de otros)
          // O espacio vacío para mantener el mismo espaciado cuando no se muestra el avatar
          if (isGroup && !isMe)
            shouldShowAvatar
                ? Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 4),
                    child: GestureDetector(
                      onTap: onAvatarTap,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        backgroundImage:
                            message.senderPhoto != null &&
                                message.senderPhoto!.isNotEmpty
                            ? NetworkImage(message.senderPhoto!)
                            : null,
                        child:
                            message.senderPhoto == null ||
                                message.senderPhoto!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 16,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              )
                            : null,
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 40,
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
                          // Nombre del remitente en grupos (solo en el primer mensaje del grupo)
                          if (isGroup && !isMe && showSender && showSenderName)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                senderDisplayName,
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
                                l10n.editedLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 9,
                                  color: isMe
                                      ? theme.colorScheme.onPrimary.withValues(
                                          alpha: 0.6,
                                        )
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                timeFormat.format(message.timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: isMe
                                      ? theme.colorScheme.onPrimary.withValues(
                                          alpha: 0.7,
                                        )
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
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
                          // Nombre del remitente en grupos (solo en el primer mensaje del grupo)
                          if (isGroup && !isMe && showSender && showSenderName)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                senderDisplayName,
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
                                      ? l10n.messageDeleted
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
                                      ? theme.colorScheme.onPrimary.withValues(
                                          alpha: 0.7,
                                        )
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
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
