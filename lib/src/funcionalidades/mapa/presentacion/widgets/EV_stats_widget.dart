import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/info_card_widget.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/bloc/station_list_bloc.dart';


class EVStatsWidget extends StatelessWidget {
  const EVStatsWidget({
    super.key,
    required this.station,
  });

  final EVStationDetails station;

  final Color _cardBackgroundColor = const Color(0xFFF5F5F7);

  @override
  Widget build(BuildContext context) {
    final bool isFast = station.isSuperFast ?? false;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // --- Favorite toggle button ---
        BlocBuilder<StationListBloc, StationListState>(
          builder: (context, state) {
            // Find the current station's favorite status from the bloc's state
            final currentStation = (state is StationListLoaded || state is StationListToggleError)
                ? (state is StationListLoaded ? state.stations : (state as StationListToggleError).stations)
                    .where((s) => s.id == station.id)
                    .firstOrNull
                : null;
            final isFavorite = currentStation?.isFavorite ?? station.isFavorite;
            final starColor = switch (isFavorite) {
              true => Colors.yellow[700],
              false => null,
              null => Colors.grey[300],
            };
            return IconButton(
              icon: Icon(
                (isFavorite ?? false) ? Icons.star : Icons.star_border,
                color: starColor,
              ),
              onPressed: () {
                context.read<StationListBloc>().add(
                  ToggleFavoriteEvent(stationId: station.id),
                );
              },
            );
          },
        ),
        const SizedBox(width: 8),
        // --- Card 1: Disponibilidad ---
        Expanded(
          child: InfoCard(
            icon: Icons.ev_station_rounded,
            label: l10n.available,
            value:
                '${station.availableSlots ?? "-"} / ${station.totalSlots ?? "-"}',
            color: Colors.green,
            backgroundColor: _cardBackgroundColor,
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
            backgroundColor: _cardBackgroundColor,
          ),
        ),
      ],
    );
  }
}