import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'station_details_extension_widget.dart'; 
import 'station_shared_widgets.dart'; 

class StationFeaturesWidget extends StatelessWidget {
  final StationDetails station;
  final bool isBike;

  const StationFeaturesWidget({
    super.key,
    required this.station,
    required this.isBike,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (isBike && station is BicycleStationDetails)
            _buildBikeFeatures(context, station as BicycleStationDetails, l10n)
          else if (!isBike && station is EVStationDetails)
            _buildEVFeatures(context, station as EVStationDetails, l10n),
        ],
      ),
    );
  }

  Widget _buildBikeFeatures(BuildContext context, BicycleStationDetails details, AppLocalizations l10n) {
    return Column(
      children: [
        DetailRow(
          icon: Icons.info_outline_rounded,
          label: l10n.state,
          value: details.state?.localized(context) ?? "-",
        ),
        const SectionDivider(),
        DetailFeatureRow(
          icon: Icons.electric_bolt_rounded,
          label: l10n.electricRecharge,
          isActive: details.electricRechargeStation,
        ),
        const SectionDivider(),
        DetailFeatureRow(
          icon: Icons.anchor_rounded,
          label: l10n.canAnchorBikes,
          isActive: details.canAnchorBikes,
        ),
        const SectionDivider(),
        DetailFeatureRow(
          icon: Icons.vpn_key_rounded,
          label: l10n.canRentBikes,
          isActive: details.canRentBikes,
        ),
      ],
    );
  }

  Widget _buildEVFeatures(BuildContext context, EVStationDetails details, AppLocalizations l10n) {
    return Column(
      children: [
        DetailRow(
          icon: Icons.lock_open_rounded,
          label: l10n.accessType,
          value: details.accessType ?? "-",
        ),
        const SectionDivider(),
        DetailFeatureRow(
          icon: Icons.flash_on_rounded,
          label: l10n.superFast,
          isActive: details.isSuperFast,
        ),
      ],
    );
  }
}