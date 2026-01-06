import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/services/search_history_service.dart';

void main() {
  late SearchHistoryService service;

  setUp(() {
    service = SearchHistoryService();
    // Clear SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    // Clear SharedPreferences after each test
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  group('SearchHistoryService', () {
    test('should save bike searches and limit to max 5', () async {
      final stationIds = ['id1', 'id2', 'id3', 'id4', 'id5', 'id6', 'id7'];
      
      await service.saveBikeSearches(stationIds);
      
      final saved = await service.getBikeSearches();
      expect(saved.length, 5);
      expect(saved, ['id1', 'id2', 'id3', 'id4', 'id5']);
    });

    test('should save ev searches and limit to max 5', () async {
      final stationIds = ['id1', 'id2', 'id3', 'id4', 'id5', 'id6'];
      
      await service.saveEvSearches(stationIds);
      
      final saved = await service.getEvSearches();
      expect(saved.length, 5);
      expect(saved, ['id1', 'id2', 'id3', 'id4', 'id5']);
    });

    test('should save less than 5 bike searches', () async {
      final stationIds = ['id1', 'id2', 'id3'];
      
      await service.saveBikeSearches(stationIds);
      
      final saved = await service.getBikeSearches();
      expect(saved.length, 3);
      expect(saved, ['id1', 'id2', 'id3']);
    });

    test('should save less than 5 ev searches', () async {
      final stationIds = ['id1', 'id2'];
      
      await service.saveEvSearches(stationIds);
      
      final saved = await service.getEvSearches();
      expect(saved.length, 2);
      expect(saved, ['id1', 'id2']);
    });

    test('should return empty list when no bike searches saved', () async {
      final saved = await service.getBikeSearches();
      expect(saved, isEmpty);
    });

    test('should return empty list when no ev searches saved', () async {
      final saved = await service.getEvSearches();
      expect(saved, isEmpty);
    });

    test('should clear all searches', () async {
      await service.saveBikeSearches(['id1', 'id2']);
      await service.saveEvSearches(['id3', 'id4']);
      
      await service.clearAllSearches();
      
      final bikeSearches = await service.getBikeSearches();
      final evSearches = await service.getEvSearches();
      
      expect(bikeSearches, isEmpty);
      expect(evSearches, isEmpty);
    });

    test('should clear bike searches only', () async {
      await service.saveBikeSearches(['id1', 'id2']);
      await service.saveEvSearches(['id3', 'id4']);
      
      await service.clearSearchesByType(true);
      
      final bikeSearches = await service.getBikeSearches();
      final evSearches = await service.getEvSearches();
      
      expect(bikeSearches, isEmpty);
      expect(evSearches, ['id3', 'id4']);
    });

    test('should clear ev searches only', () async {
      await service.saveBikeSearches(['id1', 'id2']);
      await service.saveEvSearches(['id3', 'id4']);
      
      await service.clearSearchesByType(false);
      
      final bikeSearches = await service.getBikeSearches();
      final evSearches = await service.getEvSearches();
      
      expect(bikeSearches, ['id1', 'id2']);
      expect(evSearches, isEmpty);
    });

    test('should overwrite existing bike searches', () async {
      await service.saveBikeSearches(['id1', 'id2']);
      await service.saveBikeSearches(['id3', 'id4', 'id5']);
      
      final saved = await service.getBikeSearches();
      expect(saved, ['id3', 'id4', 'id5']);
    });

    test('should overwrite existing ev searches', () async {
      await service.saveEvSearches(['id1', 'id2']);
      await service.saveEvSearches(['id3', 'id4']);
      
      final saved = await service.getEvSearches();
      expect(saved, ['id3', 'id4']);
    });

    test('should handle empty list for bike searches', () async {
      await service.saveBikeSearches([]);
      
      final saved = await service.getBikeSearches();
      expect(saved, isEmpty);
    });

    test('should handle empty list for ev searches', () async {
      await service.saveEvSearches([]);
      
      final saved = await service.getEvSearches();
      expect(saved, isEmpty);
    });
  });
}

