import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _bikeSearchesKey = 'recent_bike_searches';
  static const String _evSearchesKey = 'recent_ev_searches';
  static const int _maxRecentSearches = 5;

  /// Guardar búsquedas recientes de bicicletas
  Future<void> saveBikeSearches(List<String> stationIds) async {
    final prefs = await SharedPreferences.getInstance();
    final limitedIds = stationIds.take(_maxRecentSearches).toList();
    await prefs.setStringList(_bikeSearchesKey, limitedIds);
  }

  /// Guardar búsquedas recientes de vehículos eléctricos
  Future<void> saveEvSearches(List<String> stationIds) async {
    final prefs = await SharedPreferences.getInstance();
    final limitedIds = stationIds.take(_maxRecentSearches).toList();
    await prefs.setStringList(_evSearchesKey, limitedIds);
  }

  /// Obtener búsquedas recientes de bicicletas
  Future<List<String>> getBikeSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bikeSearchesKey) ?? [];
  }

  /// Obtener búsquedas recientes de vehículos eléctricos
  Future<List<String>> getEvSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_evSearchesKey) ?? [];
  }

  /// Limpiar todas las búsquedas recientes
  Future<void> clearAllSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bikeSearchesKey);
    await prefs.remove(_evSearchesKey);
  }

  /// Limpiar búsquedas de un tipo específico
  Future<void> clearSearchesByType(bool isBike) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(isBike ? _bikeSearchesKey : _evSearchesKey);
  }
}