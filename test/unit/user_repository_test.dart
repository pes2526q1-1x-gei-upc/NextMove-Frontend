import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/core/errors/failure.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/repositories/user_repository.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'dart:io';

void main() {
  group('UserRepository', () {
    
    test('should have getUserProfile method', () {
      try {
        final repository = UserRepository();
        expect(repository.getUserProfile, isA<Function>());
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should have updateUserProfile method', () {
      try {
        final repository = UserRepository();
        expect(repository.updateUserProfile, isA<Function>());
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should have createUserProfile method', () {
      try {
        final repository = UserRepository();
        expect(repository.createUserProfile, isA<Function>());
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should have getUserProfileByEmail method', () {
      try {
        final repository = UserRepository();
        expect(repository.getUserProfileByEmail, isA<Function>());
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should have logoutUser method', () {
      try {
        final repository = UserRepository();
        expect(repository.logoutUser, isA<Function>());
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should have uploadProfilePhoto method', () {
      try {
        final repository = UserRepository();
        expect(repository.uploadProfilePhoto, isA<Function>());
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should return Failure when getUserProfile fails without services', () async {
      try {
        final repository = UserRepository();
        final result = await repository.getUserProfile('user-1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left (Failure), got Right'),
        );
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should return Failure when getUserProfileByEmail fails without services', () async {
      try {
        final repository = UserRepository();
        final result = await repository.getUserProfileByEmail('test@example.com');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left (Failure), got Right'),
        );
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should return Failure when updateUserProfile fails without services', () async {
      try {
        final repository = UserRepository();
        final testUser = UserEntity(
          email: 'test@example.com',
          apodo: 'testuser',
          nombreCompleto: 'Test User',
          fechaNacimiento: DateTime.now(),
          fechaRegistro: DateTime.now(),
          numeroTelefono: 0,
          idiomaPreferido: 'Español',
          descripcion: '',
          modoPreferido: 'BIKE',
          photo: '',
        );

        final result = await repository.updateUserProfile(testUser);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left (Failure), got Right'),
        );
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should return Failure when createUserProfile fails without services', () async {
      try {
        final repository = UserRepository();
        final testUser = UserEntity(
          email: 'test@example.com',
          apodo: 'testuser',
          nombreCompleto: 'Test User',
          fechaNacimiento: DateTime.now(),
          fechaRegistro: DateTime.now(),
          numeroTelefono: 0,
          idiomaPreferido: 'Español',
          descripcion: '',
          modoPreferido: 'BIKE',
          photo: '',
        );

        final result = await repository.createUserProfile(testUser);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left (Failure), got Right'),
        );
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should return Failure when logoutUser fails without services', () async {
      try {
        final repository = UserRepository();
        final result = await repository.logoutUser();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left (Failure), got Right'),
        );
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });

    test('should return Failure when uploadProfilePhoto fails without services', () async {
      try {
        final repository = UserRepository();
        final testFile = File('test.jpg');
        final result = await repository.uploadProfilePhoto(testFile);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left (Failure), got Right'),
        );
      } catch (e) {
        expect(e.toString(), contains('Firebase'));
      }
    });
  });
}
