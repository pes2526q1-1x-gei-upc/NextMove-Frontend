import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';

class ChallengeDetailsPage extends StatelessWidget {
  const ChallengeDetailsPage({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.name),
      ),
      body: Center(
        child: Text(challenge.description),
      ),
    );
  }
}