import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/domain/bike_detection_response.dart';

void main() {
  group('BikeDetectionResponse', () {
    test('should create BikeDetectionResponse from valid JSON with data', () {
      final json = {
        'success': true,
        'message': 'Bike detected',
        'code': '200',
        'data': {
          'hasBike': true,
          'confidence': 85.5,
          'count': 1,
          'items': [
            {
              'class': 1,
              'class_name': 'bicycle',
              'confidence': 0.85,
              'bbox': [10.0, 20.0, 30.0, 40.0],
            },
          ],
        },
      };

      final response = BikeDetectionResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message, 'Bike detected');
      expect(response.code, '200');
      expect(response.data, isNotNull);
      expect(response.data!.hasBike, true);
      expect(response.data!.confidence, 85.5);
      expect(response.data!.count, 1);
      expect(response.data!.items.length, 1);
    });

    test('should create BikeDetectionResponse without data', () {
      final json = {
        'success': false,
        'message': 'No bike detected',
        'code': '404',
      };

      final response = BikeDetectionResponse.fromJson(json);

      expect(response.success, false);
      expect(response.message, 'No bike detected');
      expect(response.code, '404');
      expect(response.data, isNull);
    });

    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final response = BikeDetectionResponse.fromJson(json);

      expect(response.success, false);
      expect(response.message, '');
      expect(response.code, '');
      expect(response.data, isNull);
    });

    test('should handle null data field', () {
      final json = {
        'success': true,
        'message': 'Success',
        'code': '200',
        'data': null,
      };

      final response = BikeDetectionResponse.fromJson(json);

      expect(response.success, true);
      expect(response.data, isNull);
    });
  });

  group('BikeDetectionData', () {
    test('should create BikeDetectionData from valid JSON', () {
      final json = {
        'hasBike': true,
        'confidence': 90.0,
        'count': 2,
        'items': [
          {
            'class': 1,
            'class_name': 'bicycle',
            'confidence': 0.9,
            'bbox': [10.0, 20.0, 30.0, 40.0],
          },
          {
            'class': 1,
            'class_name': 'bicycle',
            'confidence': 0.85,
            'bbox': [50.0, 60.0, 70.0, 80.0],
          },
        ],
      };

      final data = BikeDetectionData.fromJson(json);

      expect(data.hasBike, true);
      expect(data.confidence, 90.0);
      expect(data.count, 2);
      expect(data.items.length, 2);
      expect(data.items[0].className, 'bicycle');
      expect(data.items[1].className, 'bicycle');
    });

    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final data = BikeDetectionData.fromJson(json);

      expect(data.hasBike, false);
      expect(data.confidence, 0.0);
      expect(data.count, 0);
      expect(data.items, isEmpty);
    });

    test('should handle empty items array', () {
      final json = {
        'hasBike': false,
        'confidence': 0.0,
        'count': 0,
        'items': [],
      };

      final data = BikeDetectionData.fromJson(json);

      expect(data.hasBike, false);
      expect(data.items, isEmpty);
    });

    test('should handle null items field', () {
      final json = {
        'hasBike': false,
        'confidence': 0.0,
        'count': 0,
      };

      final data = BikeDetectionData.fromJson(json);

      expect(data.items, isEmpty);
    });
  });

  group('DetectedItem', () {
    test('should create DetectedItem from valid JSON', () {
      final json = {
        'class': 1,
        'class_name': 'bicycle',
        'confidence': 0.85,
        'bbox': [10.0, 20.0, 30.0, 40.0],
      };

      final item = DetectedItem.fromJson(json);

      expect(item.classValue, 1);
      expect(item.className, 'bicycle');
      expect(item.confidence, 0.85);
      expect(item.bbox, [10.0, 20.0, 30.0, 40.0]);
    });

    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final item = DetectedItem.fromJson(json);

      expect(item.classValue, 0);
      expect(item.className, '');
      expect(item.confidence, 0.0);
      expect(item.bbox, isEmpty);
    });

    test('should handle bbox with integer values converted to double', () {
      final json = {
        'class': 1,
        'class_name': 'bicycle',
        'confidence': 0.85,
        'bbox': [10, 20, 30, 40], // Integers
      };

      final item = DetectedItem.fromJson(json);

      expect(item.bbox, [10.0, 20.0, 30.0, 40.0]);
    });

    test('should handle null bbox field', () {
      final json = {
        'class': 1,
        'class_name': 'bicycle',
        'confidence': 0.85,
      };

      final item = DetectedItem.fromJson(json);

      expect(item.bbox, isEmpty);
    });

    test('should handle confidence as integer converted to double', () {
      final json = {
        'class': 1,
        'class_name': 'bicycle',
        'confidence': 85, // Integer
        'bbox': [10.0, 20.0, 30.0, 40.0],
      };

      final item = DetectedItem.fromJson(json);

      expect(item.confidence, 85.0);
    });
  });
}

