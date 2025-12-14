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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.45 : 0.18);

    return Positioned(
      bottom: 160,
      right: 20,
      child: GestureDetector(
        onTap: () => context.read<MapBloc>().add(const ToggleMapTypeEvent()),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            currentMapType == MapType.normal
                ? Icons.satellite
                : Icons.map,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
        ),
      ),
    );
  }
}
