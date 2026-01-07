import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/shared/utils.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/auth_service.dart';

class BannedUserPage extends StatefulWidget {
  final Map<String, dynamic>? banInfo;
  final ValueNotifier<GraphQLClient>? client;
  final VoidCallback? onUnbanned;

  const BannedUserPage({super.key, this.banInfo, this.client, this.onUnbanned});

  @override
  State<BannedUserPage> createState() => _BannedUserPageState();
}

class _BannedUserPageState extends State<BannedUserPage> {
  Timer? _checkTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Verificar cada 1 minuto si el usuario sigue baneado
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkBanStatus();
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBanStatus() async {
    if (_isChecking || !mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.client == null) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final authService = AuthService(widget.client!.value);
      final meData = await authService.getCurrentUser();

      if (meData != null) {
        final isBanned = meData['isBanned'] as bool? ?? false;

        if (!isBanned) {
          // El usuario ya no está baneado
          if (mounted) {
            // Notificar al AuthStateHandler para que actualice el estado
            widget.onUnbanned?.call();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error verificando estado de baneo: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountSuspended)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    size: 60,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  l10n.accountSuspended,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  l10n.accountSuspendedMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.access_time_rounded,
                        l10n.endDate,
                        widget.banInfo != null
                            ? ((widget.banInfo!['isPermanent'] as bool) == true
                                  ? l10n.permanent
                                  : formatDate(
                                      DateTime.parse(
                                        widget.banInfo!['bannedUntil']
                                            as String,
                                      ).toLocal(),
                                    ))
                            : "N/A",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Icons.warning_rounded,
                        l10n.suspensionReason,
                        widget.banInfo != null
                            ? (widget.banInfo!['reason'] as String?) ?? "N/A"
                            : "N/A",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Icons.abc,
                        l10n.description,
                        widget.banInfo != null
                            ? (widget.banInfo!['description'] as String?) ??
                                  "N/A"
                            : "N/A",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Icons.email_rounded,
                        l10n.contactSupport,
                        'support@nextmove.com',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
