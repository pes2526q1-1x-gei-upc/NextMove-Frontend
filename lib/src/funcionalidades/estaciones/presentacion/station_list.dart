import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/bloc/station_list_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';

class StationList extends StatelessWidget {
  final StationType stationType;
  final double latitude;
  final double longitude;
  const StationList({
    super.key,
    required this.stationType,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => StationListBloc(context.read<StationsCache>())
        ..add(
          LoadStationListEvent(
            stationType: stationType,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      child: BlocListener<StationListBloc, StationListState>(
        listener: (context, state) {
          if (state is StationListToggleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<StationListBloc, StationListState>(
          builder: (context, state) {
            if (state is StationListLoading) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.stations),
                  elevation: 0,
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            } else if (state is StationListError) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.stations),
                  elevation: 0,
                ),
                body: Center(child: Text('${l10n.error}: ${state.message}')),
              );
            } else if (state is StationListLoaded ||
                state is StationListToggleError) {
              final allStationDetails = state is StationListLoaded
                  ? state.stations
                  : (state as StationListToggleError).stations;
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.stations),
                  elevation: 0,
                ),
                body: allStationDetails.isEmpty
                    ? const Center(
                        child: Text('No se encontraron estaciones'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        itemCount: allStationDetails.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final stationDetails = allStationDetails[i];
                          return Consumer<StationsCache>(
                            builder: (context, cache, child) {
                              final cachedStation = cache.getStation(stationDetails.id);
                              final isFavorite = cachedStation?.isFavorite ?? stationDetails.isFavorite;
                              return _StationCard(
                                station: stationDetails,
                                stationType: stationType,
                                isFavorite: isFavorite ?? false,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StationDetailsPage(
                                      stationID: stationDetails.id,
                                      stationType: stationType,
                                      stationDetails: stationDetails,
                                    ),
                                  ),
                                ),
                                onToggleFavorite: () {
                                  context.read<StationListBloc>().add(
                                    ToggleFavoriteEvent(
                                      stationId: stationDetails.id,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.stations),
                  elevation: 0,
                ),
                body: Center(child: Text(l10n.unknownState)),
              );
            }
          },
        ),
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final StationDetails station;
  final StationType stationType;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _StationCard({
    required this.station,
    required this.stationType,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine colors based on station type
    final isBike = stationType == StationType.bicycle;
    final Color mainColor = isBike ? Colors.blue : Colors.green;
    final Color iconColor = mainColor;
    final Color iconBgColor = mainColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isBike ? Icons.pedal_bike : Icons.ev_station,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Station Name (Title)
                      Text(
                        (station.name != null && station.name!.isNotEmpty) 
                            ? station.name! 
                            : (station.address ?? 'Sin nombre'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),

                      // Address (Subtitle)
                      Text(
                        station.address ?? 'Sin dirección',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Distance Row
                      if (station.distanceKm != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${station.distanceKm!.toStringAsFixed(2)} km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Extra details
                      if (!isBike && station is EVStationDetails)
                         _buildEVDetails(context, station as EVStationDetails),
                      
                      if (isBike && station is BicycleStationDetails)
                         _buildBikeDetails(context, station as BicycleStationDetails),
                    ],
                  ),
                ),
                
                // Star Button
                InkWell(
                  onTap: onToggleFavorite,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBikeDetails(BuildContext context, BicycleStationDetails station) {
    final theme = Theme.of(context);
    
    final bikes = station.availableBikes ?? 0;
    final slots = station.availableSlots ?? 0;
    final mech = station.availableMechanicalBikes;
    final elec = station.availableElectricBikes;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Available Bikes Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bikes > 0 
                      ? Colors.blue.withValues(alpha: 0.1) 
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: bikes > 0 
                          ? Colors.blue.withValues(alpha: 0.5) 
                          : Colors.red.withValues(alpha: 0.5),
                      width: 1,
                  )
                ),
                child: Row(
                  children: [
                    Icon(Icons.pedal_bike, size: 12, color: bikes > 0 ? Colors.blue : Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '$bikes',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: bikes > 0 ? Colors.blue : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Available Slots Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                     Icon(Icons.local_parking, size: 12, color: theme.colorScheme.onSurfaceVariant),
                     const SizedBox(width: 4),
                     Text(
                      '$slots Libres',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (mech != null || elec != null) ...[
             const SizedBox(height: 6),
             Text(
                '${mech ?? 0} Mecánicas • ${elec ?? 0} Eléctricas',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                ),
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildEVDetails(BuildContext context, EVStationDetails evStation) {
    final theme = Theme.of(context);
    
    // Extract info
    final available = evStation.availableSlots ?? 0;
    final total = evStation.totalSlots ?? 0;
    
    // Extract unique connector types
    final connectorTypes = evStation.connectors
            ?.map((c) => c.connectionType?.name.toUpperCase())
            .where((name) => name != null)
            .toSet() 
            .join(', ') ??
        '';

    // Find max power
    double maxPower = 0;
    if (evStation.connectors != null) {
        for (var c in evStation.connectors!) {
            if (c.powerKw != null && c.powerKw! > maxPower) {
                maxPower = c.powerKw!;
            }
        }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Availability Badge & Power
           Row(
             children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: available > 0 
                            ? Colors.green.withValues(alpha: 0.1) 
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: available > 0 
                                ? Colors.green.withValues(alpha: 0.5) 
                                : Colors.red.withValues(alpha: 0.5),
                            width: 1,
                        )
                    ),
                    child: Text(
                        '$available/$total Disp.',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: available > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                ),
                if (maxPower > 0) ...[
                    const SizedBox(width: 8),
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                            children: [
                                Icon(Icons.flash_on, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 2),
                                Text(
                                    '${maxPower.toInt()} kW',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
             ],
           ),
           
           if (connectorTypes.isNotEmpty) ...[
             const SizedBox(height: 6),
             Text(
                connectorTypes,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
             ),
           ]
        ],
      ),
    );
  }
}
