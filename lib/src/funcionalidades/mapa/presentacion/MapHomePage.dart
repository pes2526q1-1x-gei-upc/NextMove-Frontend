import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/StationList.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});
  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children: [
        Positioned.fill(
        child: Placeholder(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 80,
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Placeholder(),
                ),
              ),
              SizedBox(
                width: 80,
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Placeholder(),
                ),
              ),
              SizedBox(
                width: 80,
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Placeholder(),
                ),
              ),
            ],
          ),
        ),
      Positioned(
        left: 32,
        right: 32,
        top: 48,
        child: SizedBox(
          height: 48,
          child: Placeholder(),
        ),
      ),
      Positioned(
        top: 104, // 48 (search bar top) + 48 (search bar height) + 8 (spacing)
        right: 32,
        child: IconButton(
          icon: Icon(Icons.list),
          iconSize: 48,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => StationList()),
            );
          },
        ),
      ),
      ],
      ),
    );
  }
}
