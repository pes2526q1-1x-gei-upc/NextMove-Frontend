import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';

class RecordTrackWidget extends StatelessWidget {
  const RecordTrackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapLoadedState) {
          return const SizedBox.shrink();
        }

        final isRecording = state.isRecordingRoute;

        return Positioned(
          bottom: 30,
          right: 16,
          child: GestureDetector(
            onTap: () {
              final bloc = context.read<MapBloc>();
              if (isRecording) {
                bloc.add(const StopRouteRecordingEvent());
              } else {
                bloc.add(const StartRouteRecordingEvent());
              }
            },
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}
