import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class ChatConnectingView extends StatelessWidget {
  const ChatConnectingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.connectingToServer),
        ],
      ),
    );
  }
}

class ChatConnectionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ChatConnectionErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(l10n.connectionError, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class ChatLoadingErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const ChatLoadingErrorView({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message ?? l10n.errorLoadingFriends),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
