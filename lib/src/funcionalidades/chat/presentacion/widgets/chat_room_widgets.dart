import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/graphql/queries.dart';
import '../../dominio/entities/message.dart';
import '../bloc/chat_state.dart';
import '../utils/chat_room_data_handler.dart';
import 'message_bubble.dart';
import 'date_separator.dart';

class ChatAppBarTitle extends StatelessWidget {
  final bool isGroup;
  final String roomName;
  final String? currentRoomName;
  final String? otherUserPhoto;
  final String? currentGroupPhoto;
  final ChatState state;
  final Map<String, String>? participantsMap;
  final String? currentUserEmail;
  final VoidCallback onTap;

  const ChatAppBarTitle({
    super.key,
    required this.isGroup,
    required this.roomName,
    this.currentRoomName,
    this.otherUserPhoto,
    this.currentGroupPhoto,
    required this.state,
    this.participantsMap,
    this.currentUserEmail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          _RoomAvatar(
            isGroup: isGroup,
            currentGroupPhoto: currentGroupPhoto,
            otherUserPhoto: otherUserPhoto,
            theme: theme,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentRoomName ?? roomName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state is ChatRoomActive &&
                    (state as ChatRoomActive).usersTyping.isNotEmpty)
                  _TypingIndicator(
                    state: state as ChatRoomActive,
                    isGroup: isGroup,
                    participantsMap: participantsMap,
                    currentUserEmail: currentUserEmail,
                    theme: theme,
                    l10n: l10n,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomAvatar extends StatelessWidget {
  final bool isGroup;
  final String? currentGroupPhoto;
  final String? otherUserPhoto;
  final ThemeData theme;

  const _RoomAvatar({
    required this.isGroup,
    this.currentGroupPhoto,
    this.otherUserPhoto,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = isGroup ? currentGroupPhoto : otherUserPhoto;
    final bool hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return CircleAvatar(
      radius: 20,
      backgroundColor: isGroup
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      child: !hasPhoto
          ? Icon(
              isGroup ? Icons.group : Icons.person,
              size: 20,
              color: isGroup
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.iconTheme.color?.withValues(alpha: 0.8),
            )
          : null,
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final ChatRoomActive state;
  final bool isGroup;
  final Map<String, String>? participantsMap;
  final String? currentUserEmail;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _TypingIndicator({
    required this.state,
    required this.isGroup,
    this.participantsMap,
    this.currentUserEmail,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (!isGroup) {
      return Text(
        l10n.typing,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      );
    }

    final usersTyping = state.usersTyping;
    final filteredTypingUsers = usersTyping.entries.where((entry) {
      final userId = entry.key;
      final userName = entry.value;
      if (currentUserEmail != null) {
        if (userId == currentUserEmail || userName == currentUserEmail) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filteredTypingUsers.isEmpty) return const SizedBox.shrink();

    final typingNicknames = filteredTypingUsers.map((entry) {
      final userName = entry.value;
      if (userName.contains('@') &&
          participantsMap != null &&
          participantsMap!.containsKey(userName)) {
        return participantsMap![userName]!;
      }
      return userName;
    }).toList();

    String text = '';
    if (typingNicknames.length == 1) {
      text = '${typingNicknames.first} ${l10n.isWriting}';
    } else if (typingNicknames.length == 2) {
      text =
          '${typingNicknames[0]} ${l10n.and} ${typingNicknames[1]} ${l10n.areWriting}';
    } else {
      text =
          '${typingNicknames[0]} ${l10n.and} ${typingNicknames.length - 1} ${l10n.more} ${l10n.areWriting}';
    }

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class ChatItem {
  final Message? message;
  final DateTime? date;
  final bool isDateSeparator;

  ChatItem.message(this.message) : date = null, isDateSeparator = false;
  ChatItem.dateSeparator(this.date) : message = null, isDateSeparator = true;
}

class ChatMessageList extends StatelessWidget {
  final List<Message> messages;
  final String currentUserEmail;
  final bool isGroup;
  final Map<String, String>? participantsMap;
  final ScrollController scrollController;
  final Function(Message) onEditMessage;
  final Function(Message) onDeleteMessage;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.currentUserEmail,
    required this.isGroup,
    this.participantsMap,
    required this.scrollController,
    required this.onEditMessage,
    required this.onDeleteMessage,
  });

  List<ChatItem> _groupMessagesByDay(List<Message> messages) {
    if (messages.isEmpty) return [];

    final List<ChatItem> items = [];
    DateTime? lastDate;

    for (final message in messages) {
      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      if (lastDate == null || !_isSameDay(lastDate, messageDate)) {
        items.add(ChatItem.dateSeparator(messageDate));
        lastDate = messageDate;
      }

      items.add(ChatItem.message(message));
    }

    return items;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Message? _getMessageAtVisualIndex(List<ChatItem> items, int visualIndex) {
    final actualIndex = items.length - 1 - visualIndex;
    if (actualIndex < 0 || actualIndex >= items.length) return null;
    return items[actualIndex].message;
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupMessagesByDay(messages);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final item = groupedItems[groupedItems.length - 1 - index];

        if (item.isDateSeparator && item.date != null) {
          return DateSeparator(date: item.date!);
        } else if (item.message != null) {
          final message = item.message!;
          final isMe = message.isSentByMe(currentUserEmail);

          bool showAvatar = true;
          bool showSenderName = true;

          if (isGroup && !isMe) {
            final moreRecentMessage = index > 0
                ? _getMessageAtVisualIndex(groupedItems, index - 1)
                : null;
            if (moreRecentMessage != null &&
                moreRecentMessage.senderId == message.senderId) {
              showAvatar = false;
            }

            final moreAncientMessage = _getMessageAtVisualIndex(
              groupedItems,
              index + 1,
            );
            if (moreAncientMessage != null &&
                moreAncientMessage.senderId == message.senderId) {
              showSenderName = false;
            }
          }

          if (isMe && !message.deleted) {
            return Dismissible(
              key: Key('message_${message.id}'),
              direction: DismissDirection.endToStart,
              dismissThresholds: const {DismissDirection.endToStart: 0.15},
              movementDuration: const Duration(milliseconds: 200),
              resizeDuration: const Duration(milliseconds: 200),
              background: _DismissibleBackground(theme: theme),
              confirmDismiss: (direction) =>
                  _showDeleteConfirmation(context, l10n, theme),
              onDismissed: (_) {
                onDeleteMessage(message);
                _showDeletedSnackBar(context, l10n, theme);
              },
              child: MessageBubble(
                message: message,
                isMe: isMe,
                isGroup: isGroup,
                participantsMap: participantsMap,
                showAvatar: showAvatar,
                showSenderName: showSenderName,
                onEditMessage: onEditMessage,
              ),
            );
          }

          return MessageBubble(
            message: message,
            isMe: isMe,
            isGroup: isGroup,
            participantsMap: participantsMap,
            showAvatar: showAvatar,
            showSenderName: showSenderName,
            onEditMessage: onEditMessage,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
        content: Text(l10n.deleteMessageConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

  void _showDeletedSnackBar(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(l10n.messageDeleted),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _DismissibleBackground extends StatelessWidget {
  final ThemeData theme;
  const _DismissibleBackground({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
    );
  }
}

class ChatBottomBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onSend;
  final VoidCallback onCancelEdit;
  final ValueChanged<String> onChanged;

  const ChatBottomBar({
    super.key,
    required this.controller,
    required this.isEditing,
    required this.onSend,
    required this.onCancelEdit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: isEditing
                        ? l10n.editingMessage
                        : l10n.writeAMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
              if (isEditing) ...[
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.close),
                  onPressed: onCancelEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton.filled(
                icon: Icon(isEditing ? Icons.check : Icons.send),
                onPressed: onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatEmptyMessagesView extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const ChatEmptyMessagesView({
    super.key,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        l10n.noMessagesYet,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isGroup;
  final String roomId;
  final String roomName;
  final String? currentRoomName;
  final String? otherUserPhoto;
  final String? currentGroupPhoto;
  final ChatState state;
  final String currentUserEmail;
  final Function(BuildContext, List<Message>, String, Map<String, String>?)
  onNavigateToDetails;

  const ChatRoomAppBar({
    super.key,
    required this.isGroup,
    required this.roomId,
    required this.roomName,
    this.currentRoomName,
    this.otherUserPhoto,
    this.currentGroupPhoto,
    required this.state,
    required this.currentUserEmail,
    required this.onNavigateToDetails,
  });

  @override
  Widget build(BuildContext context) {
    final messages = state is ChatRoomActive
        ? (state as ChatRoomActive).messages
        : <Message>[];

    return AppBar(
      automaticallyImplyLeading: true,
      title: isGroup
          ? Query(
              options: QueryOptions(
                document: gql(GraphQLQueries.myChatsQuery),
                fetchPolicy: FetchPolicy.cacheAndNetwork,
              ),
              builder: (result, {fetchMore, refetch}) {
                final participantsMap = ChatRoomDataHandler.getParticipantsMap(
                  result.data,
                  roomId,
                );
                return ChatAppBarTitle(
                  isGroup: isGroup,
                  roomName: roomName,
                  currentRoomName: currentRoomName,
                  otherUserPhoto:
                      ChatRoomDataHandler.getOtherUserPhoto(
                        messages,
                        currentUserEmail,
                      ) ??
                      otherUserPhoto,
                  currentGroupPhoto: currentGroupPhoto,
                  state: state,
                  participantsMap: participantsMap,
                  currentUserEmail: currentUserEmail,
                  onTap: () => onNavigateToDetails(
                    context,
                    messages,
                    currentUserEmail,
                    participantsMap,
                  ),
                );
              },
            )
          : ChatAppBarTitle(
              isGroup: isGroup,
              roomName: roomName,
              currentRoomName: currentRoomName,
              otherUserPhoto:
                  ChatRoomDataHandler.getOtherUserPhoto(
                    messages,
                    currentUserEmail,
                  ) ??
                  otherUserPhoto,
              currentGroupPhoto: currentGroupPhoto,
              state: state,
              currentUserEmail: currentUserEmail,
              onTap: () => onNavigateToDetails(
                context,
                messages,
                currentUserEmail,
                null,
              ),
            ),
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
