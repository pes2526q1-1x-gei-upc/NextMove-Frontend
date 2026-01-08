import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/info_card_widget.dart';

class BicycleStatsWidget extends StatelessWidget {
  const BicycleStatsWidget({super.key, required this.station});

  final BicycleStationDetails station;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardColor = Theme.of(context).cardColor;
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: InfoCard(
            icon: Icons.pedal_bike_rounded,
            label: l10n.mechanical,
            value: '${station.availableMechanicalBikes ?? "-"}',
            color: Colors.orange,
            backgroundColor: cardColor,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: InfoCard(
            icon: Icons.electric_bike_rounded,
            label: l10n.electric,
            value: '${station.availableElectricBikes ?? "-"}',
            color: Colors.blue,
            backgroundColor: cardColor,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: InfoCard(
            icon: Icons.local_parking_rounded,
            label: l10n.free,
            value: '${station.availableSlots ?? "-"}',
            color: Colors.grey,
            backgroundColor: cardColor,
          ),
        ),
      ],
    );
  }
}
