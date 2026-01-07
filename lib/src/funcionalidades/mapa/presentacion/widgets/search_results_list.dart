import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';


class SearchResultsList extends StatelessWidget {
  final bool isSearchBarFocused;
  
  const SearchResultsList({
    super.key,
    required this.isSearchBarFocused,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if(state is! MapLoadedState){
          if (kDebugMode) {
            print('State is not MapLoadedState');
          }
          return const SizedBox.shrink();
        }
        
        // CAMBIAR: Priorizar las búsquedas recientes cuando está enfocado y no hay búsqueda activa
        final hasActiveSearch = state.searchQuery != null && state.searchQuery!.length >= 3;
        
        if (isSearchBarFocused && !hasActiveSearch) {
          final recentSearches = state.currentModeRecentSearches;
          if (recentSearches.isNotEmpty) {
            return _buildRecentSearchesList(context, state, recentSearches);
          } else {
            return const SizedBox.shrink();
          }
        }
        
        if(!state.isSearching) {
          if (kDebugMode) {
            //print('Not searching, hiding');
          }
          return const SizedBox.shrink();
        }

        if(state.searchQuery != null && state.searchQuery!.length < 3) {
          return _messageCard(
            context,
            loc.minCharsSearchHint,
            Icons.search,
          );
        }

        // Si la búsqueda no devolvió resultados
        if (state.searchResults.isEmpty) {
          debugPrint("Search Results : ${state.searchResults}");
          return _messageCard(
            context,
            loc.anyStationsFound,
            Icons.location_off,
          );
        }

        return _buildResultsList(context, state);
      }
    );
  }

  Widget _messageCard(BuildContext context, String message, IconData icon) {
    final theme = Theme.of(context);
    final shadowColor =
        Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.18);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesList(
    BuildContext context, 
    MapLoadedState state, 
    List<StationDetails> recentSearches,
  ) {
    final theme = Theme.of(context);
    final modeColor = state.currentMode == StationType.bicycle
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 
              theme.brightness == Brightness.dark ? 0.5 : 0.18,
            ),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), 
            child: Text(
              'Búsquedas recientes',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: ListView.separated( 
              shrinkWrap: true,
              padding: EdgeInsets.zero, 
              itemCount: recentSearches.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.5,
                indent: 60, 
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final station = recentSearches[index];
                return ListTile(
                  dense: true, 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(
                    state.currentMode == StationType.bicycle
                        ? Icons.pedal_bike
                        : Icons.ev_station,
                    color: modeColor,
                    size: 24,
                  ),
                  title: Text(
                    station.name!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: station.address != null
                    ? Text(
                        station.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                  trailing: Icon(
                    Icons.history,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  onTap: () {
                    debugPrint('✅ Búsqueda reciente: ${station.name}');
                    FocusScope.of(context).unfocus();
                    context.read<MapBloc>().add(SelectSearchResultEvent(station));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, MapLoadedState state) {
    final theme = Theme.of(context);
    final modeColor = state.currentMode == StationType.bicycle
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 
              theme.brightness == Brightness.dark ? 0.5 : 0.18,
            ),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated( 
        shrinkWrap: true,
        padding: EdgeInsets.zero, 
        itemCount: state.searchResults.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 0.5,
          indent: 60,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final station = state.searchResults[index];
          return ListTile(
            dense: true, 
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
            leading: Icon(
              state.currentMode == StationType.bicycle
                  ? Icons.pedal_bike
                  : Icons.ev_station,
              color: modeColor,
              size: 24, 
            ),
            title: Text(
              station.name!,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: station.address != null
              ? Text(
                  station.address!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
            onTap: () {
              debugPrint('✅ Pulsado: ${station.name}');
              FocusScope.of(context).unfocus();
              context.read<MapBloc>().add(SelectSearchResultEvent(station));
            },
          );
        },
      ),
    );
  }
}