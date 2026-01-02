import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({
    super.key,
    required this.date,
  });

  static String formatDateHeader(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final l10n = AppLocalizations.of(context)!;

    if (messageDate == today) {
      return l10n.today;
    } else if (messageDate == yesterday) {
      return l10n.yesterday;
    } else {
      // Formatear fecha según el locale del contexto
      final locale = Localizations.localeOf(context);
      final dateFormat = DateFormat('EEEE, d \'de\' MMMM', locale.toString());
      return dateFormat.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = formatDateHeader(date, context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateText,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

