import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class StationList extends StatelessWidget {
  const StationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stations'),
      ),
      body: ListView(
        children: [
          for (int i = 0; i < 50; i++)
            ListTile(
              title: Text('Station $i'),
            ),
        ],
      ),
    );
  }
}