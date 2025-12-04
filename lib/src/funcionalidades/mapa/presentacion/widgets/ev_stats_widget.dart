import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/info_card_widget.dart';


class EVStatsWidget extends StatelessWidget {
  const EVStatsWidget({
    super.key,
    required this.station,
  });

  final EVStationDetails station;

  @override
  Widget build(BuildContext context) {
    final bool isFast = station.isSuperFast ?? false;
    final l10n = AppLocalizations.of(context)!;
    final cardColor = Theme.of(context).cardColor;
    return Row(
      children: [
        // --- Card 1: Disponibilidad ---
        Expanded(
          child: InfoCard(
            icon: Icons.ev_station_rounded,
            label: l10n.available,
            value:
                '${station.availableSlots ?? "-"} / ${station.totalSlots ?? "-"}',
            color: Colors.green,
            backgroundColor: cardColor,
          ),
        ),
        const SizedBox(width: 12),

        // --- Card 2: Velocidad de Carga ---
        Expanded(
          child: InfoCard(
            icon: Icons.bolt_rounded,
            label: l10n.charge,
            value: isFast ? l10n.fast : l10n.normal,
            color: isFast ? Colors.amber[700]! : Colors.blue,
            backgroundColor: cardColor,
          ),
        ),
      ],
    );
  }
}