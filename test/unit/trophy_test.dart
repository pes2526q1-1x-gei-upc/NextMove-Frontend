import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/competition/challenges/domain/trophy.dart';

void main() {
  group('Trophy', () {
    test('fromChallengeName should create trophy with correct id and imagePath', () {
      const challengeName = 'Test Challenge';
      final trophy = Trophy.fromChallengeName(challengeName);

      final expectedId = challengeName.hashCode % Trophy.numTrophies + 1;
      final expectedImagePath = 'assets/trophies/$expectedId.png';

      expect(trophy.id, expectedId);
      expect(trophy.imagePath, expectedImagePath);
    });

    test('numTrophies should be 15', () {
      expect(Trophy.numTrophies, 15);
    });

    test('all should return list of 15 trophies', () {
      expect(Trophy.all.length, 15);
    });

    test('all trophies should have correct ids and imagePaths', () {
      for (int i = 0; i < Trophy.all.length; i++) {
        final trophy = Trophy.all[i];
        expect(trophy.id, i + 1);
        expect(trophy.imagePath, 'assets/trophies/${i + 1}.png');
      }
    });

    test('getById should return correct trophy', () {
      final trophy = Trophy.getById(5);
      expect(trophy.id, 5);
      expect(trophy.imagePath, 'assets/trophies/5.png');
    });

    test('getById should throw when id not found', () {
      expect(() => Trophy.getById(99), throwsA(isA<StateError>()));
    });

    test('constructor should create trophy with given id and imagePath', () {
      const trophy = Trophy(10, 'custom/path.png');
      expect(trophy.id, 10);
      expect(trophy.imagePath, 'custom/path.png');
    });
  });
}