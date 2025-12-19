import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../dominio/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showSender;
  final bool showMyAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSender = true,
    this.showMyAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: message.senderPhoto != null && message.senderPhoto!.isNotEmpty
                  ? NetworkImage(message.senderPhoto!)
                  : null,
              child: message.senderPhoto == null || message.senderPhoto!.isEmpty
                  ? Text(
                      message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showSender && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isMe
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                ),
              ],
            ),
          ),
          if (showMyAvatar && isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondaryContainer,
              backgroundImage: message.senderPhoto != null && message.senderPhoto!.isNotEmpty
                  ? NetworkImage(message.senderPhoto!)
                  : null,
              child: message.senderPhoto == null || message.senderPhoto!.isEmpty
                  ? Text(
                      message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    )
                  : null,
            ),
          ] else if (isMe)
            const SizedBox(width: 40),
          if (!isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }
}