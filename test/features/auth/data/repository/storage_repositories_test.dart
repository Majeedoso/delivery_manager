import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/auth/data/datasource/secure_storage_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/repository/secure_storage_repository.dart';
import 'package:delivery_manager/features/auth/data/repository/token_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

/// The token the app sends with every request, and the email kept for
/// "remember me": both on secure storage, both answering with Either.
void main() {
  group('TokenRepository', () {
    late MockTokenRemoteDataSource server;
    late TokenRepository tokens;

    setUp(() {
      server = MockTokenRemoteDataSource();
      tokens = TokenRepository(
        localDataSource: TokenLocalDataSource(),
        remoteDataSource: server,
      );
    });

    test('saves, reads, checks and clears the token', () async {
      expect(await tokens.saveToken('1|abc'), const Right<Failure, bool>(true));
      expect(await tokens.getToken(), const Right<Failure, String?>('1|abc'));
      expect(await tokens.hasToken(), const Right<Failure, bool>(true));

      expect(await tokens.clearToken(), const Right<Failure, bool>(true));
      expect(await tokens.getToken(), const Right<Failure, String?>(null));
      expect(await tokens.hasToken(), const Right<Failure, bool>(false));
    });

    test('the server\'s verdict on the token comes back as it is', () async {
      when(() => server.validateToken(any())).thenAnswer((_) async => false);

      expect(
        await tokens.validateToken('1|abc'),
        const Right<Failure, bool>(false),
      );
      verify(() => server.validateToken('1|abc')).called(1);
    });

    test(
      'no connection is a network failure, a server error a server one',
      () async {
        when(() => server.validateToken(any())).thenThrow(
          const NetworkException(message: 'Token validation timed out'),
        );
        expect(
          await tokens.validateToken('t'),
          const Left<Failure, bool>(
            NetworkFailure('Token validation timed out'),
          ),
        );

        when(() => server.validateToken(any())).thenThrow(
          const ServerException(message: 'Token validation failed: 500'),
        );
        expect(
          await tokens.validateToken('t'),
          const Left<Failure, bool>(
            ServerFailure('Token validation failed: 500'),
          ),
        );
      },
    );

    test('storage that throws becomes a failure', () async {
      final storage = MockTokenLocalDataSource();
      when(() => storage.saveToken(any())).thenThrow(Exception('disk'));
      when(() => storage.getToken()).thenThrow(Exception('disk'));
      when(() => storage.clearToken()).thenThrow(Exception('disk'));
      when(() => storage.hasToken()).thenThrow(Exception('disk'));
      tokens = TokenRepository(
        localDataSource: storage,
        remoteDataSource: server,
      );

      expect((await tokens.saveToken('t')).isLeft(), isTrue);
      expect((await tokens.getToken()).isLeft(), isTrue);
      expect((await tokens.clearToken()).isLeft(), isTrue);
      expect((await tokens.hasToken()).isLeft(), isTrue);
    });
  });

  group('SecureStorageRepository', () {
    test('remembers and forgets the email', () async {
      final remember = SecureStorageRepository(SecureStorageLocalDataSource());

      await remember.saveCredentials(
        email: 'karim@example.dz',
        password: 'pw',
        rememberMe: true,
      );
      expect(
        await remember.loadCredentials(),
        isA<Right<Failure, Map<String, String?>>>().having(
          (r) => r.value,
          'credentials',
          {'email': 'karim@example.dz', 'rememberMe': 'true'},
        ),
      );
      expect(
        await remember.hasSavedCredentials(),
        const Right<Failure, bool>(true),
      );

      await remember.clearCredentials();
      expect(
        await remember.hasSavedCredentials(),
        const Right<Failure, bool>(false),
      );
    });

    test('storage that throws becomes a failure', () async {
      final storage = MockSecureStorageLocalDataSource();
      when(
        () => storage.saveCredentials(
          email: any(named: 'email'),
          password: any(named: 'password'),
          rememberMe: any(named: 'rememberMe'),
        ),
      ).thenThrow(Exception('keystore'));
      when(() => storage.loadCredentials()).thenThrow(Exception('keystore'));
      when(() => storage.clearCredentials()).thenThrow(Exception('keystore'));
      when(
        () => storage.hasSavedCredentials(),
      ).thenThrow(Exception('keystore'));
      final remember = SecureStorageRepository(storage);

      expect(
        (await remember.saveCredentials(
          email: 'e',
          password: 'p',
          rememberMe: true,
        )).isLeft(),
        isTrue,
      );
      expect((await remember.loadCredentials()).isLeft(), isTrue);
      expect((await remember.clearCredentials()).isLeft(), isTrue);
      expect((await remember.hasSavedCredentials()).isLeft(), isTrue);
    });
  });
}
