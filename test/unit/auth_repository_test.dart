import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/registro/datos/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    test('should initialize correctly', () {
      final repository = AuthRepository();
      expect(repository, isNotNull);
    });

    test('should have signInWithEmailAndPassword method', () {
      final repository = AuthRepository();
      expect(repository.signInWithEmailAndPassword, isA<Function>());
    });

    test('should have signUpWithEmailAndPassword method', () {
      final repository = AuthRepository();
      expect(repository.signUpWithEmailAndPassword, isA<Function>());
    });

    test('should have signInWithGoogle method', () {
      final repository = AuthRepository();
      expect(repository.signInWithGoogle, isA<Function>());
    });

    test('should have isEmailRegisteredAndWithGoogle method', () {
      final repository = AuthRepository();
      expect(repository.isEmailRegisteredAndWithGoogle, isA<Function>());
    });

    test('should have deleteAccount method', () {
      final repository = AuthRepository();
      expect(repository.deleteAccount, isA<Function>());
    });

    test('should return Failure when signInWithEmailAndPassword fails without services', () async {
      final repository = AuthRepository();
      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left (Failure), got Right'),
      );
    });

    test('should return Failure when signUpWithEmailAndPassword fails without services', () async {
      final repository = AuthRepository();
      final result = await repository.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left (Failure), got Right'),
      );
    });

    test('should return Failure when signInWithGoogle fails without services', () async {
      final repository = AuthRepository();
      final result = await repository.signInWithGoogle();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left (Failure), got Right'),
      );
    });

    test('should return Failure when isEmailRegisteredAndWithGoogle fails without services', () async {
      final repository = AuthRepository();
      final result = await repository.isEmailRegisteredAndWithGoogle('test@example.com');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left (Failure), got Right'),
      );
    });

    test('should return Failure when deleteAccount fails without services', () async {
      final repository = AuthRepository();
      final result = await repository.deleteAccount('password123');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Expected Left (Failure), got Right'),
      );
    });
  });
}
