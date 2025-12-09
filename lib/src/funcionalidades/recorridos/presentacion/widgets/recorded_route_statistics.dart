import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/statistics_widget.dart';

class RecordedTrackStatistics extends StatelessWidget {
  final RecordedTrack track;

  const RecordedTrackStatistics({super.key, 
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final duration = track.startTime.difference(track.endTime).abs();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeStatistics),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            StatisticsWidget(track: track, elapsedTime: duration, l10n: l10n),
          ],
        ),
      ),
    );
  }
}
