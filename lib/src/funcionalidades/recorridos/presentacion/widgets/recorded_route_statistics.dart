import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/statistics_widget.dart';
import 'package:nextmove_app/src/shared/domain/track_statistics.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:share_plus/share_plus.dart';

class RecordedRouteStatistics extends StatelessWidget {
  final RecordedRoute track;

  const RecordedRouteStatistics({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final duration = track.startTime!.difference(track.endTime!).abs();

    WidgetsToImageController widgetsToImageController =
        WidgetsToImageController();

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
            WidgetsToImage(
              controller: widgetsToImageController,
              child: Column(
                children: [
                  Text(
                    l10n.routeRecordedOn(date, time),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatisticsWidget(
                    track: RecordedRouteWrapper(track),
                    elapsedTime: duration,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  try {
                    Uint8List? widgetImageBytes = await widgetsToImageController
                        .capturePng(
                          pixelRatio: 4.0,
                        );
                    SharePlus.instance.share(
                      ShareParams(
                        title: l10n.routeStatistics,
                        text: l10n.shareRouteStatisticsMessage,
                        files: widgetImageBytes != null
                            ? [
                                XFile.fromData(
                                  widgetImageBytes,
                                  mimeType: 'image/png',
                                  name:
                                      'route_${track.endTime!.toIso8601String()}_statistics.png',
                                ),
                              ]
                            : null,
                      ),
                    );
                  } on Exception catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10n.errorOccurred}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
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
