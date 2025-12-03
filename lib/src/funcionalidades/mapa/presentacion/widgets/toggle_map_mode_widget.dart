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
    return Positioned(
      bottom: 30,
      left: 100,
      right: 100,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              // Bike
              Expanded(
                child: Material(
                  color: currentMode == StationType.bicycle
                      ? Colors.blue.shade600
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<MapBloc>().add(ChangeModeEvent(StationType.bicycle)),
                    child: Center(
                      child: Icon(
                        Icons.directions_bike,
                        color: currentMode == StationType.bicycle
                            ? Colors.white
                            : Colors.grey[700],
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              // Separator
              Container(
                width: 1,
                color: Colors.grey[300],
              ),
              // Car
              Expanded(
                child: Material(
                  color: currentMode == StationType.electricVehicle
                      ? Colors.green.shade600
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<MapBloc>().add(ChangeModeEvent(StationType.electricVehicle)),
                    child: Center(
                      child: Icon(
                        Icons.electric_car,
                        color: currentMode == StationType.electricVehicle
                            ? Colors.white
                            : Colors.grey[700],
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
