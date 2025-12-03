import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



// A diferencia de antes, ahora este widget recibe el tipo de mapa actual y una función de callback para alternar el tipo de mapa.
// Lo que es la gestion del estado se hará en el bloc   
class MapTypeToggleWidget extends StatelessWidget {
  final MapType currentMapType;

  const MapTypeToggleWidget({
    super.key,
    required this.currentMapType,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 160,
      right: 20,
      child: GestureDetector(
        onTap: () => context.read<MapBloc>().add(const ToggleMapTypeEvent()),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(
            currentMapType == MapType.normal
                ? Icons.satellite
                : Icons.map,
            color: Colors.grey[700],
            size: 28,
          ),
        ),
      ),
    );
  }
}
