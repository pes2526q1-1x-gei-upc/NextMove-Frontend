import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/datos/repositories/station_repository.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/station_details_page.dart';

class FavoriteStationsList extends StatefulWidget {
  final StationType stationType;

  const FavoriteStationsList({
    super.key,
    required this.stationType,
  });

  @override
  State<FavoriteStationsList> createState() => _FavoriteStationsListState();
}

class _FavoriteStationsListState extends State<FavoriteStationsList> {
  final StationRepository _repository = StationRepository();
  List<String>? _favoriteIds;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final result = widget.stationType == StationType.bicycle
        ? await _repository.getFavBikeStationIds()
        : await _repository.getFavCarStationIds();

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.toString();
          });
        },
        (ids) {
          setState(() {
            _favoriteIds = ids;
            _isLoading = false;
          });
        },
      );
    }
  }

  Future<void> _removeFavorite(String stationId) async {
    // Optimistic update
    setState(() {
      _favoriteIds?.remove(stationId);
    });

    final result = await _repository.setStationFavoriteStatus(
      stationId,
      widget.stationType,
      false,
    );

    result.fold(
      (failure) {
        // Revert if failed
        if (mounted) {
          setState(() {
            _favoriteIds?.add(stationId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar: ${failure.toString()}')),
            );
          });
        }
      },
      (_) {
        // Success (already updated UI)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.favoriteStations),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.favoriteStations),
        ),
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    return Consumer<StationsCache>(
      builder: (context, cache, child) {
        final stations = _favoriteIds!
            .map((id) => cache.getStation(id))
            .where((s) => s != null)
            .cast<StationDetails>()
            .toList();

        if (stations.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.favoriteStations),
            ),
            body: const Center(
              child: Text('No tienes estaciones favoritas aún.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.favoriteStations),
            elevation: 0,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: stations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final station = stations[index];
              return _FavoriteStationCard(
                station: station,
                stationType: widget.stationType,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StationDetailsPage(
                        stationID: station.id,
                        stationType: widget.stationType,
                        stationDetails: station,
                      ),
                    ),
                  );
                },
                onRemove: () => _removeFavorite(station.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _FavoriteStationCard extends StatelessWidget {
  final StationDetails station;
  final StationType stationType;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteStationCard({
    required this.station,
    required this.stationType,
    required this.onTap,
    required this.onRemove,
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
                      
                      // Distance Row (Only for Bikes)
                      if (isBike && station.distanceKm != null) ...[
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
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.star,
                      color: Colors.amber,
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
