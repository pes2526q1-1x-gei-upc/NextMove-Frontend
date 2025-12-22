// lib/src/funcionalidades/chat/presentacion/widgets/chat_list_widgets.dart
import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

/// Widget para mostrar un elemento de chat de amigo
class FriendChatItem extends StatelessWidget {
  final Map<String, dynamic> friend;
  final VoidCallback onTap;

  const FriendChatItem({
    super.key,
    required this.friend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final friendName = friend['name'] as String;
    final friendPhoto = friend['photo'] as String?;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: friendPhoto != null && friendPhoto.isNotEmpty
            ? NetworkImage(friendPhoto)
            : null,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: friendPhoto == null || friendPhoto.isEmpty
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
      subtitle: Text(
        l10n.tapToChat,
        style: theme.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      onTap: onTap,
    );
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

/// Widget para mostrar la lista de grupos (vacía por ahora)
class GroupsList extends StatelessWidget {
  final ThemeData theme;

  const GroupsList({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Este método debería recibir filteredGroups como parámetro cuando se implemente búsqueda de grupos
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noGroupsAvailable,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.groupsComingSoon,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para la barra de búsqueda y toggle
class ChatSearchBar extends StatefulWidget {
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
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  late AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: Theme.of(context).brightness == Brightness.dark
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
                controller: widget.controller,
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                          hintText: widget.showFriends ? l10n.searchChats : l10n.searchGroups,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            widget.controller.clear();
                            widget.onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          width: 96,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: Theme.of(context).brightness == Brightness.dark
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
                isSelected: [widget.showFriends, !widget.showFriends],
                onPressed: (index) {
                  widget.onToggleChanged(index == 0);
                },
                borderRadius: BorderRadius.zero,
                selectedColor: Theme.of(context).colorScheme.onPrimary,
                fillColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderWidth: 0,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                children: const [
                  Icon(Icons.person, size: 20),
                  Icon(Icons.group, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}