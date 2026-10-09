import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fake_backend.dart';
import '../../../../helpers/locator.dart';

/// At start-up the saved token is checked with GET /auth/user. Only a 401
/// means the token is invalid; anything else (a timeout, a server error) says
/// nothing about the token and must not sign the manager out.
void main() {
  late FakeBackend backend;
  late TokenRemoteDataSource source;

  setUp(() {
    backend = FakeBackend();
    source = TokenRemoteDataSource(
      dio: testDio(backend),
      logger: silentLogger(),
    );
  });

  test('sends the token to /auth/user', () async {
    backend.reply('GET', '/auth/user', body: ok(userJson()));

    await source.validateToken('1|abcdef');

    expect(
      backend.last('GET', '/auth/user').headers['Authorization'],
      'Bearer 1|abcdef',
    );
  });

  test('200 means valid', () async {
    backend.reply('GET', '/auth/user', body: ok(userJson()));

    expect(await source.validateToken('t'), isTrue);
  });

  test('401 means invalid', () async {
    backend.reply(
      'GET',
      '/auth/user',
      status: 401,
      body: failure('Unauthenticated.'),
    );

    expect(await source.validateToken('t'), isFalse);
  });

  test('a server error is a server problem, not an invalid token', () async {
    backend.reply('GET', '/auth/user', status: 500, body: htmlErrorPage);

    await expectLater(
      source.validateToken('t'),
      throwsA(isA<ServerException>()),
    );
  });

  test('a timeout or no connection is a network problem', () async {
    backend.fail('GET', '/auth/user', DioExceptionType.receiveTimeout);
    await expectLater(
      source.validateToken('t'),
      throwsA(isA<NetworkException>()),
    );

    backend.fail('GET', '/auth/user', DioExceptionType.connectionError);
    await expectLater(
      source.validateToken('t'),
      throwsA(isA<NetworkException>()),
    );
  });

  test('no answer within 8 seconds is a network problem', () {
    fakeAsync((async) {
      backend.hang('GET', '/auth/user');
      Object? error;
      source
          .validateToken('t')
          .then<void>((_) {}, onError: (Object e) => error = e);

      async.elapse(const Duration(seconds: 7));
      expect(error, isNull);
      async.elapse(const Duration(seconds: 1));

      expect(
        error,
        isA<NetworkException>().having(
          (e) => e.message,
          'message',
          'Token validation timed out',
        ),
      );
    });
  });
}
