import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Estaciones Favoritas'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Estaciones Favoritas'),
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
              title: const Text('Estaciones Favoritas'),
            ),
            body: const Center(
              child: Text('No hay estaciones favoritas en caché o lista vacía'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Estaciones Favoritas'),
          ),
          body: ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return ListTile(
                title: Text(station.address ?? 'Sin dirección'),
                subtitle: Text(
                  station.distanceKm != null
                      ? '${station.distanceKm!.toStringAsFixed(2)} km'
                      : '',
                ),
                trailing: const Icon(Icons.favorite, color: Colors.red),
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
              );
            },
          ),
        );
      },
    );
  }
}
