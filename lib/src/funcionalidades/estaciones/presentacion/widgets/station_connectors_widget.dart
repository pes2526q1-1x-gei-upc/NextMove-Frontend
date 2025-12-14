import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'station_details_extension_widget.dart';
import 'station_shared_widgets.dart';

class StationConnectorsWidget extends StatelessWidget {
  final EVStationDetails details;

  const StationConnectorsWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connectors = details.connectors;

    if (connectors == null || connectors.isEmpty) {
      final theme = Theme.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(text: l10n.connectors),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "N/A",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: l10n.connectors),
        ...connectors.map((c) => _ConnectorCard(connector: c)),
      ],
    );
  }
}

class _ConnectorCard extends StatelessWidget {
  final Connector connector;
  const _ConnectorCard({required this.connector});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = connector.status?.color ?? Colors.grey;
    final statusBg = statusColor.withValues(alpha: isDark ? 0.2 : 0.12);
    final mutedColor = theme.colorScheme.onSurfaceVariant;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.3 : 1,
            ),
            child: Icon(
              Icons.electrical_services_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connector.connectionType?.localized(context) ?? l10n.unknown,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  connector.powerKw != null ? '${connector.powerKw} kW' : l10n.unknownPower,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              connector.status?.localized(context) ?? "N/A",
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}