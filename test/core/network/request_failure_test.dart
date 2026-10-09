import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/request_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_json.dart';

/// What a failed request tells the manager: the server's reason (it writes
/// it in the app's language), or that the network failed, in the two texts
/// the app translates. Dio's and Dart's own texts never reach a page.
void main() {
  final request = RequestOptions(path: '/manager/system-payments/70/confirm');

  DioException refused(int status, Object? body) => DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: request, statusCode: status, data: body),
  );

  DioException unanswered(DioExceptionType type) =>
      DioException(requestOptions: request, type: type, message: 'socket');

  group('the server answered', () {
    test('its reason, and its name for the refusal', () {
      final said = requestFailureOf(
        refused(404, failure('Paiement introuvable.', errorCode: 'NOT_FOUND')),
      );

      expect(
        said,
        isA<ServerException>()
            .having((e) => e.message, 'message', 'Paiement introuvable.')
            .having((e) => e.errorCode, 'errorCode', 'NOT_FOUND'),
      );
    });

    test('a reason without a name', () {
      final said = requestFailureOf(
        refused(403, failure('Your account has been suspended.')),
      );

      expect(
        said,
        isA<ServerException>()
            .having(
              (e) => e.message,
              'message',
              'Your account has been suspended.',
            )
            .having((e) => e.errorCode, 'errorCode', isNull),
      );
    });

    test('a refused field: the sentence about it, not "Validation '
        'failed"', () {
      final said = requestFailureOf(
        refused(
          422,
          validationFailure({
            'cancellation_reason': [
              'Le champ motif d\'annulation ne doit pas dépasser 500 '
                  'caractères.',
            ],
          }, message: 'Échec de la validation'),
        ),
      );

      expect(
        said,
        isA<ServerException>()
            .having(
              (e) => e.message,
              'message',
              'Le champ motif d\'annulation ne doit pas dépasser 500 '
                  'caractères.',
            )
            .having((e) => e.errorCode, 'errorCode', 'VALIDATION_ERROR'),
      );
    });

    test('several refused fields: the first one\'s sentence', () {
      final said = requestFailureOf(
        refused(
          422,
          validationError({
            'start_date': ['The start date field is required.'],
            'end_date': ['The end date field is required.'],
          }),
        ),
      );

      expect(
        (said as ServerException).message,
        'The start date field is required.',
      );
    });

    test('refused fields that say nothing leave the answer\'s message', () {
      for (final errors in <Object?>[
        const <String, dynamic>{},
        const {'reason': <String>[]},
        const {
          'reason': [' '],
        },
        const {'reason': 12},
        'not a list of fields',
        null,
      ]) {
        final said = requestFailureOf(
          refused(422, {
            'success': false,
            'message': 'Validation failed',
            'errors': errors,
          }),
        );

        expect(
          (said as ServerException).message,
          'Validation failed',
          reason: '$errors',
        );
      }
    });

    test('a field\'s sentence written alone, without a list, is read too', () {
      final said = requestFailureOf(
        refused(422, {
          'message': 'Validation failed',
          'errors': {'reason': 'A reason is needed.'},
        }),
      );

      expect((said as ServerException).message, 'A reason is needed.');
    });

    test('an error page, an empty answer or an empty reason: a server error, '
        'in words the app translates', () {
      for (final body in <Object?>[
        htmlErrorPage,
        null,
        '',
        const ['a', 'list'],
        const {'success': false},
        const {'message': '   '},
        const {'message': 500},
      ]) {
        expect(
          requestFailureOf(refused(502, body)),
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Server error occurred')
              .having((e) => e.errorCode, 'errorCode', isNull),
          reason: '$body',
        );
      }
    });
  });

  group('the server did not answer', () {
    test('too slow: a timeout', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          requestFailureOf(unanswered(type)),
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Request timeout',
          ),
          reason: '$type',
        );
      }
    });

    test('anything else: no connection', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.unknown,
        DioExceptionType.cancel,
        DioExceptionType.badCertificate,
      ]) {
        expect(
          requestFailureOf(unanswered(type)),
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Network connection error',
          ),
          reason: '$type',
        );
      }
    });
  });

  test('what is not a request\'s failure (a mistake in the app) is a server '
      'error for the manager, never Dart\'s text', () {
    for (final error in <Object>[
      TypeError(),
      const FormatException('Unexpected character'),
      StateError('no element'),
      'a string',
    ]) {
      expect(
        requestFailureOf(error),
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Server error occurred',
        ),
        reason: '$error',
      );
    }
  });
}
