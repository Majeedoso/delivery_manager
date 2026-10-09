import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';
import '../../helpers/fakes.dart';
import '../../helpers/pump.dart';

/// The Dio that ServicesLocator.init() builds adds the manager's token and
/// language to every request, and turns a 403 ACCOUNT_NOT_APPROVED into a
/// forced logout. These tests use that exact Dio with only its transport
/// replaced.
void main() {
  late FakeBackend backend;
  late MockTokenRepository tokens;

  /// The production Dio after init(), with [prefs] as the saved preferences.
  Future<Dio> appDio({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    await ServicesLocator().init();
    tokens = MockTokenRepository();
    when(
      () => tokens.getToken(),
    ).thenAnswer((_) async => const Right('abc123'));
    await sl.unregister<BaseTokenRepository>();
    sl.registerLazySingleton<BaseTokenRepository>(() => tokens);
    backend = FakeBackend()..reply('GET', '/auth/user', body: ok({'id': 1}));
    return sl<Dio>()..httpClientAdapter = backend;
  }

  group('the token', () {
    test('is sent as a Bearer header', () async {
      final dio = await appDio();

      await dio.get<Object?>('/auth/user');

      expect(
        backend.last('GET', '/auth/user').headers['Authorization'],
        'Bearer abc123',
      );
    });

    test('is left out when none is stored', () async {
      final dio = await appDio();
      when(() => tokens.getToken()).thenAnswer((_) async => const Right(null));

      await dio.get<Object?>('/auth/user');

      expect(
        backend.last('GET', '/auth/user').headers,
        isNot(contains('Authorization')),
      );
    });

    test('is left out when storage cannot be read', () async {
      final dio = await appDio();
      when(
        () => tokens.getToken(),
      ).thenAnswer((_) async => const Left(CacheFailure('keystore corrupted')));

      await dio.get<Object?>('/auth/user');

      expect(
        backend.last('GET', '/auth/user').headers,
        isNot(contains('Authorization')),
      );
    });
  });

  group('Accept-Language', () {
    for (final language in ['ar', 'en', 'fr']) {
      test('follows the chosen language ($language)', () async {
        final dio = await appDio(prefs: {'selected_language': language});

        await dio.get<Object?>('/auth/user');

        expect(
          backend.last('GET', '/auth/user').headers['Accept-Language'],
          language,
        );
      });
    }

    test('is Arabic when no language was chosen yet', () async {
      final dio = await appDio();

      await dio.get<Object?>('/auth/user');

      expect(
        backend.last('GET', '/auth/user').headers['Accept-Language'],
        'ar',
      );
    });

    test('is Arabic when the saved language is not supported', () async {
      final dio = await appDio(prefs: {'selected_language': 'de'});

      await dio.get<Object?>('/auth/user');

      expect(
        backend.last('GET', '/auth/user').headers['Accept-Language'],
        'ar',
        reason: 'the backend only speaks ar, en and fr',
      );
    });
  });

  group('a suspended account', () {
    test('a 403 ACCOUNT_NOT_APPROVED signals it once', () async {
      final dio = await appDio();
      backend.reply(
        'GET',
        '/manager/users',
        status: 403,
        body: failure('Account suspended', errorCode: 'ACCOUNT_NOT_APPROVED'),
      );
      var signals = 0;
      final subscription = accountSuspendedEvents.stream.listen(
        (_) => signals++,
      );
      addTearDown(subscription.cancel);

      await expectLater(
        dio.get<Object?>('/manager/users'),
        throwsA(isA<DioException>()),
      );
      await flushAsync();

      expect(signals, 1, reason: 'MyApp sends the manager back to sign in');
    });

    test('any other 403 is not a suspension', () async {
      final dio = await appDio();
      backend.reply(
        'GET',
        '/manager/users',
        status: 403,
        body: failure('This action is unauthorized.'),
      );
      var signals = 0;
      final subscription = accountSuspendedEvents.stream.listen(
        (_) => signals++,
      );
      addTearDown(subscription.cancel);

      await expectLater(
        dio.get<Object?>('/manager/users'),
        throwsA(isA<DioException>()),
      );
      await flushAsync();

      expect(signals, 0);
    });
  });

  test('requests go to BASE_URL from .env', () async {
    final dio = await appDio();

    await dio.get<Object?>('/auth/user');

    expect(dio.options.baseUrl, 'http://test.local/api');
    expect(backend.requests.single.path, '/auth/user');
  });
}
