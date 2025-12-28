import 'package:flutter/material.dart';

class FavoriteStationsList extends StatelessWidget {
  const FavoriteStationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones Favoritas'),
      ),
      body: const Center(
        child: Text('Aquí se mostrarán tus estaciones favoritas'),
      ),
    );
  }
}
