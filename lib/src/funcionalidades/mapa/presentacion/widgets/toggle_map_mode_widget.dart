import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToggleMapModeWidget extends StatelessWidget {
  final StationType currentMode; // Viene del estado del BLoC
  
  const ToggleMapModeWidget({
    super.key,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final bikeActiveColor = Colors.blue.shade600;
    final evActiveColor = Colors.green.shade600;
    final inactiveIconColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final overlayShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.45 : 0.18),
        spreadRadius: 1,
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];

    return Positioned(
      bottom: 30,
      left: 100,
      right: 100,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: overlayShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              // Bike
              Expanded(
                child: Material(
                  color: currentMode == StationType.bicycle
                      ? bikeActiveColor
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<MapBloc>().add(ChangeModeEvent(StationType.bicycle)),
                    child: Center(
                      child: Icon(
                        Icons.directions_bike,
                        color: currentMode == StationType.bicycle
                            ? Colors.white
                            : inactiveIconColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              // Separator
              Container(
                width: 1,
                color: theme.dividerColor,
              ),
              // Car
              Expanded(
                child: Material(
                  color: currentMode == StationType.electricVehicle
                      ? evActiveColor
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<MapBloc>().add(ChangeModeEvent(StationType.electricVehicle)),
                    child: Center(
                      child: Icon(
                        Icons.electric_car,
                        color: currentMode == StationType.electricVehicle
                            ? Colors.white
                            : inactiveIconColor,
                        size: 28,
                      ),
                    ),
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
