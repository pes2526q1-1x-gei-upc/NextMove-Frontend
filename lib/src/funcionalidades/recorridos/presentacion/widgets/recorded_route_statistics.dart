import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/statistics_widget.dart';
import 'package:nextmove_app/src/shared/domain/track_statistics.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class RecordedRouteStatistics extends StatelessWidget {
  final RecordedRoute track;

  const RecordedRouteStatistics({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final duration = track.startTime!.difference(track.endTime!).abs();

    WidgetsToImageController widgetsToImageController =
        WidgetsToImageController();

    // Wrap your widget
    // WidgetsToImage(
    //   controller: widgetsToImageController,
    //   child: Container(
    //     width: 200,
    //     height: 100,
    //     color: Colors.blue,
    //     child: const Center(
    //       child: Text(
    //         'Hello World!',
    //         style: TextStyle(color: Colors.white, fontSize: 20),
    //       ),
    //     ),
    //   ),
    // )

    // // Capture the widget
    // Uint8List? bytes = await widgetsToImageController.capture();

    String date = track.startTime != null
        ? '${track.startTime!.day.toString().padLeft(2, '0')}/${track.startTime!.month.toString().padLeft(2, '0')}/${track.startTime!.year}'
        : '';
    String time = track.startTime != null
        ? '${track.startTime!.hour.toString().padLeft(2, '0')}:${track.startTime!.minute.toString().padLeft(2, '0')}'
        : '';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.routeStatistics)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.routeRecordedOn(date, time),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            StatisticsWidget(
              track: RecordedRouteWrapper(track),
              elapsedTime: duration,
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: Text(
                  l10n.share,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
