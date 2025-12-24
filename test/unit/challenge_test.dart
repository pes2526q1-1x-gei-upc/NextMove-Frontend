import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/challenge.dart';

void main() {
  group('Challenge', () {
    group('fromJson', () {
      test('should parse valid JSON data correctly', () {
        final jsonData = {
          'description': 'Complete a 10km run',
          'distance': 10.0,
          'ending_date': '1740009600000',
          'name': '10km Challenge',
          'points': 100,
          'starting_date': '1738368000000'
        };

        final challenge = Challenge.fromJson(jsonData);

        expect(challenge.description, 'Complete a 10km run');
        expect(challenge.distance, 10.0);
        expect(challenge.name, '10km Challenge');
        expect(challenge.points, 100);
        expect(challenge.endingDate, DateTime.fromMillisecondsSinceEpoch(1740009600000));
        expect(challenge.startingDate, DateTime.fromMillisecondsSinceEpoch(1738368000000));
      });

      test('should handle integer distance', () {
        final jsonData = {
          'description': 'Test challenge',
          'distance': 5, // Integer instead of double
          'ending_date': '1740009600000',
          'name': 'Test',
          'points': 50,
          'starting_date': '1738368000000',
        };

        final challenge = Challenge.fromJson(jsonData);

        expect(challenge.distance, 5.0);
      });
    });
  });
}