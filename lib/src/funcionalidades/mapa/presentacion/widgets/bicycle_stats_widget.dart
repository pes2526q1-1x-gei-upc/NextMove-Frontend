


import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/info_card_widget.dart';

class BicycleStatsWidget extends StatelessWidget {
  const BicycleStatsWidget({
    super.key,
    required this.station,
  });

  final BicycleStationDetails station;

  final Color _cardBackgroundColor = const Color(0xFFF5F5F7);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // --- Card 1: Mecánicas ---
        Expanded(
          child: InfoCard(
            icon: Icons.pedal_bike_rounded,
            label: l10n.mechanical,
            value: '${station.availableMechanicalBikes ?? "-"}',
            color: Colors.orange,
            backgroundColor: _cardBackgroundColor,
          ),
        ),
        const SizedBox(width: 12),

        // --- Card 2: Eléctricas ---
        Expanded(
          child: InfoCard(
            icon: Icons.electric_bike_rounded,
            label: l10n.electric,
            value: '${station.availableElectricBikes ?? "-"}',
            color: Colors.blue,
            backgroundColor: _cardBackgroundColor,
          ),
        ),
        const SizedBox(width: 12),

        // --- Card 3: Slots Libres ---
        Expanded(
          child: InfoCard(
            icon: Icons.local_parking_rounded,
            label: l10n.free,
            value: '${station.availableSlots ?? "-"}',
            color: Colors.grey,
            backgroundColor: _cardBackgroundColor,
          ),
        ),
      ],
    );
  }
}