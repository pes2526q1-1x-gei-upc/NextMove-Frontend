import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/graphql/queries.dart';
import '../pages/edit_group_page.dart';

class GroupInfoCard extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String fallbackName;
  final String? fallbackDescription;
  final bool isCurrentUserAdmin;
  final VoidCallback onEditTap;

  const GroupInfoCard({
    super.key,
    required this.chat,
    required this.fallbackName,
    this.fallbackDescription,
    required this.isCurrentUserAdmin,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = chat['photo'] as String?;
    final name = chat['name'] as String? ?? fallbackName;
    final description = chat['description'] as String? ?? fallbackDescription;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: (photo != null && photo.isNotEmpty)
                    ? NetworkImage(photo)
                    : null,
                child: (photo == null || photo.isEmpty)
                    ? Icon(
                        Icons.group,
                        size: 50,
                        color: theme.colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              if (isCurrentUserAdmin)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditTap,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ParticipantTile extends StatelessWidget {
  final Map<String, dynamic> participant;
  final bool isCurrentUser;
  final bool isAdmin;
  final bool isCurrentUserAdmin;
  final VoidCallback onTap;
  final VoidCallback? onToggleAdmin;
  final VoidCallback? onKick;
  final Widget trailing;

  const ParticipantTile({
    super.key,
    required this.participant,
    required this.isCurrentUser,
    required this.isAdmin,
    required this.isCurrentUserAdmin,
    required this.onTap,
    this.onToggleAdmin,
    this.onKick,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final nickname = participant['nickname'] as String? ?? 'Usuario';
    final photo = participant['photoUrl'] as String?;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: (photo != null && photo.isNotEmpty)
                    ? NetworkImage(photo)
                    : null,
                child: (photo == null || photo.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 24,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nickname,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: isCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          _AdminBadge(theme: theme),
                        ],
                      ],
                    ),
                    if (isCurrentUser)
                      Text(
                        l10n.you,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminBadge extends StatelessWidget {
  final ThemeData theme;
  const _AdminBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Admin',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class GroupActionButtons extends StatelessWidget {
  final VoidCallback onAddParticipants;
  final VoidCallback onLeaveGroup;
  final bool isLeaving;

  const GroupActionButtons({
    super.key,
    required this.onAddParticipants,
    required this.onLeaveGroup,
    this.isLeaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAddParticipants,
            icon: const Icon(Icons.person_add, size: 20),
            label: Text(l10n.add),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLeaving ? null : onLeaveGroup,
            icon: isLeaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.exit_to_app, size: 20),
            label: Text(l10n.leave),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DeleteGroupButton extends StatelessWidget {
  final VoidCallback onDelete;
  final bool isDeleting;

  const DeleteGroupButton({
    super.key,
    required this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isDeleting ? null : onDelete,
        icon: isDeleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.delete_forever, size: 20),
        label: Text(
          l10n.deleteGroup,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

class ChatRoomDetailsErrorView extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final String errorMessage;
  final VoidCallback? onRetry;

  const ChatRoomDetailsErrorView({
    super.key,
    required this.l10n,
    required this.theme,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(l10n.error),
          const SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class ChatRoomDetailsNotFoundView extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const ChatRoomDetailsNotFoundView({
    super.key,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(l10n.groupNotFound, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class ChatRoomDetailsAdminEditButton extends StatelessWidget {
  final String chatId;
  final String chatName;
  final String? chatDescription;
  final String currentUserEmail;
  final VoidCallback onRefresh;
  final Function(Map<String, dynamic>) onGroupDataUpdated;

  const ChatRoomDetailsAdminEditButton({
    super.key,
    required this.chatId,
    required this.chatName,
    this.chatDescription,
    required this.currentUserEmail,
    required this.onRefresh,
    required this.onGroupDataUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Query(
      options: QueryOptions(
        document: gql(GraphQLQueries.myChatsQuery),
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.hasException || result.data == null) {
          return const SizedBox.shrink();
        }
        final chats = result.data?['myChats'] as List<dynamic>? ?? [];
        final chat = chats.firstWhere(
          (c) => c['id'] == chatId,
          orElse: () => null,
        );
        if (chat == null) return const SizedBox.shrink();

        final participants = chat['participants'] as List<dynamic>? ?? [];
        final isCurrentUserAdmin = participants.any(
          (p) =>
              p['userEmail'] == currentUserEmail &&
              (p['isAdmin'] as bool? ?? false),
        );
        if (!isCurrentUserAdmin) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: const Icon(Icons.edit),
          tooltip: l10n.editGroupTooltip,
          onPressed: () async {
            final editResult = await Navigator.of(context)
                .push<Map<String, dynamic>?>(
                  MaterialPageRoute(
                    builder: (context) => EditGroupPage(
                      chatId: chatId,
                      currentName: chat['name'] as String? ?? chatName,
                      currentDescription:
                          chat['description'] as String? ?? chatDescription,
                      currentPhotoUrl: chat['photo'] as String?,
                    ),
                  ),
                );
            if (editResult != null) {
              onRefresh();
              onGroupDataUpdated(editResult);
            }
          },
        );
      },
    );
  }
}
