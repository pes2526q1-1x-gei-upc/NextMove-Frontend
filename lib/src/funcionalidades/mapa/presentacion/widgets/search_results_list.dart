import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';


class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if(state is! MapLoadedState){
          return SizedBox.shrink();
        }
        
        if(!state.isSearching) {
          return SizedBox.shrink();
        }

        if(state.searchQuery != null && state.searchQuery!.length < 3) {
          return _messageCard(
            loc.minCharsSearchHint,
            Icons.search,
            );
        }

        // Si la búsqueda no devolvió resultados
        if (state.searchResults.isEmpty) {
          debugPrint("Search Results : ${state.searchResults}");
          return _messageCard(
            loc.anyStationsFound,
            Icons.location_off,
          );
        }

        return _buildResultsList(context, state);

      }
    );
  }

  Widget _messageCard(String message, IconData icon) {
     return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildResultsList(BuildContext context, MapLoadedState state) {
    return Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 350),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.searchResults.length,
                itemBuilder: (context, index) {
                  final station = state.searchResults[index];
                  return ListTile(
                    leading: Icon(
                      state.currentMode == StationType.bicycle
                          ? Icons.pedal_bike
                          : Icons.ev_station,
                      color: state.currentMode == StationType.bicycle
                          ? Colors.blue
                          : Colors.green,
                    ),
                    title: Text(
                      station.name!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      station.address!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      debugPrint('✅ Pulsado: ${station.name}');
                      final currentState = state;
                      context.read<MapBloc>().onMarkerTapped(station, currentState);
                      context.read<MapBloc>().add(const ClearSearchEvent());
                    },
                  );
                },
              ),
            ),
          );
  }
}