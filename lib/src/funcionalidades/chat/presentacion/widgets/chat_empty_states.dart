import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class EmptyChatsPlaceholder extends StatelessWidget {
  const EmptyChatsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(l10n.noFriendsYet, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.addFriendsToStartChatting),
        ],
      ),
    );
  }
}

class EmptyGroupsPlaceholder extends StatelessWidget {
  const EmptyGroupsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          Text(
            l10n.noGroupsYet,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(l10n.createAGroupToStart),
        ],
      ),
    );
  }
}
