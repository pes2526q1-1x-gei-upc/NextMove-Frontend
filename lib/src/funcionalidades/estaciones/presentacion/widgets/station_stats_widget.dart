import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';

class StationStatsWidget extends StatelessWidget {
  final StationDetails station;
  final bool isBike;

  const StationStatsWidget({
    super.key,
    required this.station,
    required this.isBike,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isBike && station is BicycleStationDetails) {
      final bikeDetails = station as BicycleStationDetails;
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.availableMechanicalBikes,
              value: bikeDetails.availableMechanicalBikes?.toString() ?? "-",
              icon: Icons.pedal_bike_rounded,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: l10n.availableElectricBikes,
              value: bikeDetails.availableElectricBikes?.toString() ?? "-",
              icon: Icons.electric_bike_rounded,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: l10n.availableAnchors,
              value: bikeDetails.availableSlots?.toString() ?? "-",
              icon: Icons.local_parking_rounded,
              color: Colors.grey,
            ),
          ),
        ],
      );
    } else if (!isBike && station is EVStationDetails) {
      final evDetails = station as EVStationDetails;
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.availableChargers,
              value: '${evDetails.availableSlots ?? "-"} / ${evDetails.totalSlots ?? "-"}',
              icon: Icons.ev_station_rounded,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: l10n.superFast,
              value: (evDetails.isSuperFast ?? false) ? l10n.fast : l10n.normal,
              icon: Icons.bolt_rounded,
              color: Colors.amber[700]!,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// Widget privado solo para uso interno de las stats
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}