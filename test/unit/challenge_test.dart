import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';

void main() {
  group('Challenge', () {
    group('fromJson', () {
      test('should parse valid JSON data correctly', () {
        final jsonData = {
          'id': 'challenge-1',
          'company': {
            'name': 'Test Company',
            'email': 'test@company.com',
            'url': 'https://testcompany.com',
            'description': 'A test company',
            'logo': 'https://testcompany.com/logo.png',
          },
          'description': 'Complete a 10km run',
          'distance': 10000.0,
          'ending_date': '1740009600000',
          'name': '10km Challenge',
          'points': 100,
          'starting_date': '1738368000000',
          'photo': 'https://example.com/photo.jpg'
        };
        final challenge = Challenge.fromJson(jsonData);

        expect(challenge.id, 'challenge-1');
        expect(challenge.company.name, 'Test Company');
        expect(challenge.description, 'Complete a 10km run');
        expect(challenge.distance, 10.0);
        expect(challenge.name, '10km Challenge');
        expect(challenge.points, 100);
        expect(challenge.endingDate, DateTime.fromMillisecondsSinceEpoch(1740009600000));
        expect(challenge.startingDate, DateTime.fromMillisecondsSinceEpoch(1738368000000));
        expect(challenge.photo, 'https://example.com/photo.jpg');
      });

      test('should handle integer distance', () {
        final jsonData = {
          'id': 'challenge-2',
          'company': {
            'name': 'Another Company',
            'email': 'another@company.com',
            'url': 'https://anothercompany.com',
            'description': 'Another test company',
            'logo': null,
          },
          'description': 'Test challenge',
          'distance': 5000,
          'ending_date': '1740009600000',
          'name': 'Test',
          'points': 50,
          'starting_date': '1738368000000',
        };
        final challenge = Challenge.fromJson(jsonData);

        expect(challenge.id, 'challenge-2');
        expect(challenge.company.name, 'Another Company');
        expect(challenge.description, 'Test challenge');
        expect(challenge.distance, 5.0);
        expect(challenge.name, 'Test');
        expect(challenge.points, 50);
        expect(challenge.endingDate, DateTime.fromMillisecondsSinceEpoch(1740009600000));
        expect(challenge.startingDate, DateTime.fromMillisecondsSinceEpoch(1738368000000));
        expect(challenge.photo, null);
      });
    });
  });
}