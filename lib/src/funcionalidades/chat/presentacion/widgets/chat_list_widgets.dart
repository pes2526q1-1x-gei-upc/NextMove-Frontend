import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

/// Widget para mostrar un elemento de chat de amigo
class FriendChatItem extends StatefulWidget {
  final Map<String, dynamic> friend;
  final VoidCallback onTap;

  const FriendChatItem({super.key, required this.friend, required this.onTap});

  @override
  State<FriendChatItem> createState() => _FriendChatItemState();
}

class _FriendChatItemState extends State<FriendChatItem> {
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final friendName = widget.friend['name'] as String;
    final friendPhoto = widget.friend['photo'] as String?;

    final hasPhoto =
        friendPhoto != null && friendPhoto.isNotEmpty && !_imageError;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: hasPhoto ? NetworkImage(friendPhoto) : null,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        onBackgroundImageError: hasPhoto
            ? (exception, stackTrace) {
                if (mounted) {
                  setState(() {
                    _imageError = true;
                  });
                }
              }
            : null,
        child: !hasPhoto
            ? Icon(
                Icons.person,
                size: 24,
                color: theme.iconTheme.color?.withValues(alpha: 0.8),
              )
            : null,
      ),
      title: Text(
        friendName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: _buildSubtitle(theme),
      onTap: widget.onTap,
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final lastMessage = widget.friend['lastMessage'] as Map<String, dynamic>?;

    if (lastMessage != null && lastMessage['content'] != null) {
      final content = lastMessage['content'] as String? ?? '';
      if (content.isNotEmpty) {
        return Text(
          content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        );
      }
    }

    final chatId = widget.friend['chatId'] as String?;
    if (chatId == null) {
      return Text(
        l10n.tapToChat,
        style: theme.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Widget para mostrar la lista de amigos
class FriendsList extends StatelessWidget {
  final ThemeData theme;
  final List<dynamic> filteredFriends;
  final VoidCallback onRefresh;
  final Function(Map<String, dynamic>) onFriendTap;

  const FriendsList({
    super.key,
    required this.theme,
    required this.filteredFriends,
    required this.onRefresh,
    required this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: filteredFriends.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          indent: 72,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final friend = filteredFriends[index];
          return FriendChatItem(
            friend: friend,
            onTap: () => onFriendTap(friend),
          );
        },
      ),
    );
  }
}

/// Widget para mostrar un elemento de chat de grupo
class GroupChatItem extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const GroupChatItem({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final groupName = group['name'] as String? ?? l10n.group;
    final description = group['description'] as String?;
    final groupPhoto = group['photo'] as String?;
    final lastMessage = group['lastMessage'] as Map<String, dynamic>?;

    String? subtitleText;
    if (lastMessage != null && lastMessage['content'] != null) {
      final sender = lastMessage['sender'] as String?;
      final content = lastMessage['content'] as String? ?? '';
      if (content.isNotEmpty) {
        subtitleText = (sender != null && sender.isNotEmpty)
            ? '$sender: $content'
            : content;
      }
    }

    if (subtitleText == null || subtitleText.isEmpty) {
      if (description != null && description.isNotEmpty) {
        subtitleText = description;
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: groupPhoto != null ? NetworkImage(groupPhoto) : null,
        child: groupPhoto == null
            ? Icon(Icons.group, color: theme.colorScheme.onPrimaryContainer)
            : null,
      ),
      title: Text(
        groupName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitleText ?? l10n.group,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontStyle: subtitleText == null ? FontStyle.italic : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Widget para mostrar la lista de grupos
class GroupsList extends StatelessWidget {
  final ThemeData theme;
  final List<dynamic> groups;
  final VoidCallback onRefresh;
  final Function(Map<String, dynamic>) onGroupTap;

  const GroupsList({
    super.key,
    required this.theme,
    required this.groups,
    required this.onRefresh,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: groups.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 0.5,
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          indent: 72,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final group = groups[index];
          return GroupChatItem(group: group, onTap: () => onGroupTap(group));
        },
      ),
    );
  }
}

/// Widget para la barra de búsqueda y toggle
class ChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool showFriends;
  final ValueChanged<bool> onToggleChanged;
  final ValueChanged<String> onSearchChanged;

  const ChatSearchBar({
    super.key,
    required this.controller,
    required this.showFriends,
    required this.onToggleChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: theme.brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: showFriends ? l10n.searchChats : l10n.searchGroups,
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 96,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: theme.brightness == Brightness.dark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ToggleButtons(
              isSelected: [showFriends, !showFriends],
              onPressed: (index) => onToggleChanged(index == 0),
              selectedColor: theme.colorScheme.onPrimary,
              fillColor: theme.colorScheme.primary,
              color: theme.colorScheme.onSurfaceVariant,
              borderWidth: 0,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              children: const [
                Icon(Icons.person, size: 20),
                Icon(Icons.group, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Floating Action Button para crear un grupo
class ChatListFab extends StatelessWidget {
  final VoidCallback onPressed;

  const ChatListFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(l10n.createGroup),
    );
  }
}
