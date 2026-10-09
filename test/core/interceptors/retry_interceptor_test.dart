import 'package:delivery_manager/core/interceptors/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';
import '../../helpers/locator.dart';

/// The app's Dio retries failed requests up to 3 times, waiting 2, 4 and 6
/// seconds. A request may only be repeated when repeating it is harmless:
/// a POST that reached the server (it timed out on the answer, or the server
/// failed) must not run twice, or one tap on "Pay" records the payment twice
/// (D5: the driver app repeated them).
void main() {
  late FakeBackend backend;
  late Dio dio;

  setUp(() {
    backend = FakeBackend();
    dio = testDio(
      backend,
      interceptors: [RetryInterceptor(logger: silentLogger())],
    );
    // Retries go through the app's Dio from the locator, like in the app.
    registerService<Dio>(dio);
  });

  /// Sends a request under fake time and reports how it ended.
  ({List<Object> outcome, FakeAsync async}) send(
    FakeAsync async,
    String method,
    String path, {
    Object? data,
  }) {
    final outcome = <Object>[];
    dio
        .request<Object?>(
          path,
          data: data,
          options: Options(method: method),
        )
        .then(outcome.add, onError: (Object error) => outcome.add(error));
    // Dio hands the request on with a zero-length timer, not a microtask
    async.elapse(Duration.zero);
    return (outcome: outcome, async: async);
  }

  test('a timed-out GET is retried after 2, 4 and 6 seconds, then fails', () {
    fakeAsync((async) {
      backend.fail('GET', '/manager/users', DioExceptionType.receiveTimeout);

      final sent = send(async, 'GET', '/manager/users');
      expect(backend.count('GET', '/manager/users'), 1);

      async.elapse(const Duration(milliseconds: 1999));
      expect(backend.count('GET', '/manager/users'), 1, reason: 'not yet');
      async.elapse(const Duration(milliseconds: 1));
      expect(backend.count('GET', '/manager/users'), 2);
      async.elapse(const Duration(seconds: 4));
      expect(backend.count('GET', '/manager/users'), 3);
      async.elapse(const Duration(seconds: 6));
      expect(backend.count('GET', '/manager/users'), 4);

      async.elapse(const Duration(minutes: 1));
      expect(backend.count('GET', '/manager/users'), 4, reason: '3 retries');
      expect(
        sent.outcome.single,
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.receiveTimeout,
        ),
      );
    });
  });

  test('a retry that gets through returns its answer', () {
    fakeAsync((async) {
      backend.replyInTurn('GET', '/manager/users', [
        const FakeReply.failure(DioExceptionType.connectionError),
        FakeReply(200, ok(['order'])),
      ]);

      final sent = send(async, 'GET', '/manager/users');
      async.elapse(const Duration(seconds: 2));

      final response = sent.outcome.single as Response<Object?>;
      expect(response.statusCode, 200);
      expect((response.data as Map)['data'], ['order']);
    });
  });

  test('a GET the server failed (503) is retried', () {
    fakeAsync((async) {
      backend.replyInTurn('GET', '/manager/restaurants', [
        FakeReply(503, failure('Service Unavailable')),
        FakeReply(200, ok(const [])),
      ]);

      final sent = send(async, 'GET', '/manager/restaurants');
      async.elapse(const Duration(seconds: 2));

      expect(sent.outcome.single, isA<Response<Object?>>());
      expect(backend.count('GET', '/manager/restaurants'), 2);
    });
  });

  test('a client error (404) is never retried', () {
    fakeAsync((async) {
      backend.reply(
        'GET',
        '/manager/users/9/approve',
        status: 404,
        body: failure('Order not found'),
      );

      final sent = send(async, 'GET', '/manager/users/9/approve');
      async.elapse(const Duration(minutes: 1));

      expect(backend.count('GET', '/manager/users/9/approve'), 1);
      expect(sent.outcome.single, isA<DioException>());
    });
  });

  group('a POST', () {
    test('the server failed (500) is not repeated', () {
      fakeAsync((async) {
        backend.reply(
          'POST',
          '/manager/system-payments',
          status: 500,
          body: failure('Server Error'),
        );

        send(async, 'POST', '/manager/system-payments', data: {'amount': 2400});
        async.elapse(const Duration(minutes: 1));

        expect(
          backend.count('POST', '/manager/system-payments'),
          1,
          reason: 'the payment may have been saved before the error',
        );
      });
    });

    test('whose answer timed out is not repeated', () {
      fakeAsync((async) {
        backend.fail(
          'POST',
          '/manager/system-payments',
          DioExceptionType.receiveTimeout,
        );

        final sent = send(
          async,
          'POST',
          '/manager/system-payments',
          data: {'amount': 2400},
        );
        async.elapse(const Duration(minutes: 1));

        expect(
          backend.count('POST', '/manager/system-payments'),
          1,
          reason:
              'the server got the payment; sending it again records it twice',
        );
        expect(sent.outcome.single, isA<DioException>());
      });
    });

    test('that could not connect is retried: it never reached the server', () {
      fakeAsync((async) {
        backend.replyInTurn('POST', '/manager/system-payments', [
          const FakeReply.failure(DioExceptionType.connectionError),
          FakeReply(201, ok({'id': 7})),
        ]);

        final sent = send(
          async,
          'POST',
          '/manager/system-payments',
          data: {'amount': 2400},
        );
        async.elapse(const Duration(seconds: 2));

        expect((sent.outcome.single as Response<Object?>).statusCode, 201);
        expect(backend.count('POST', '/manager/system-payments'), 2);
      });
    });
  });

  test('a cancelled request is not retried', () {
    fakeAsync((async) {
      backend.fail('GET', '/manager/users', DioExceptionType.cancel);

      send(async, 'GET', '/manager/users');
      async.elapse(const Duration(minutes: 1));

      expect(backend.count('GET', '/manager/users'), 1);
    });
  });

  test('a file upload without its original fields is not sent twice', () {
    fakeAsync((async) {
      backend.fail('GET', '/upload', DioExceptionType.connectionTimeout);

      final sent = send(
        async,
        'GET',
        '/upload',
        data: FormData.fromMap({'name': 'avatar'}),
      );
      async.elapse(const Duration(minutes: 1));

      expect(
        backend.count('GET', '/upload'),
        1,
        reason: 'a sent FormData cannot be sent again without its fields',
      );
      expect(sent.outcome.single, isA<DioException>());
    });
  });
}
