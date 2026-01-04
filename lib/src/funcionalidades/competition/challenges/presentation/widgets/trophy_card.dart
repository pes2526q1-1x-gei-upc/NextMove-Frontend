import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';

class TrophyCard extends StatelessWidget {
  const TrophyCard({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
