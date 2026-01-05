import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/presentation/widgets/trophy_details_page.dart';

class TrophyCard extends StatelessWidget {
  const TrophyCard({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () {
        if (challenge.isCompleted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrophyDetailsPage(challenge: challenge),
            ),
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.trophyLockedMessage),
            ),
          );
        }
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: challenge.isCompleted
                  ? Image.asset(
                      challenge.trophy.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50);
                      },
                    )
                  : Center(child: Text('? 👀', style: TextStyle(fontSize: 36))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                challenge.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
