import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/trophy.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class TrophyDetailsPage extends StatelessWidget {
  final Challenge challenge;
  const TrophyDetailsPage({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    WidgetsToImageController widgetsToImageController =
        WidgetsToImageController();

    return Scaffold(
      appBar: AppBar(title: Text(challenge.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WidgetsToImage(
                controller: widgetsToImageController,
                child: Column(
                  children: [
                    Image.asset(
                      Trophy.fromChallengeName(challenge.name).imagePath,
                      width: 150,
                      height: 150,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 8.0,
                        bottom: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        challenge.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.trophyCongratulationsMessage(challenge.name),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    try {
                      Uint8List? widgetImageBytes =
                          await widgetsToImageController.capturePng(
                            pixelRatio: 4.0,
                          );
                      SharePlus.instance.share(
                        ShareParams(
                          title: l10n.trophyOfChallenge(challenge.name),
                          text: l10n.shareTrophyMessage(challenge.name),
                          files: widgetImageBytes != null
                              ? [
                                  XFile.fromData(
                                    widgetImageBytes,
                                    mimeType: 'image/png',
                                    name: 'trophy_${challenge.name}.png',
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
                  label: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text(
                        l10n.share,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
