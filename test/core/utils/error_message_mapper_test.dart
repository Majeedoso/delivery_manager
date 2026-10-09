import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/error_message_mapper.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every error snackbar goes through this mapper, so it decides what the
/// manager reads when something fails: the backend's own words when they are
/// written for people, a sentence in the manager's language for technical
/// failures, and never raw PHP, SQL, HTML, URLs or IP addresses.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  String shown(Object? error, [AppLocalizations? l10n]) =>
      ErrorMessageMapper.getUserFriendlyMessage(error, l10n ?? en);

  DioException failed(DioExceptionType type) => DioException(
    requestOptions: RequestOptions(path: '/x'),
    type: type,
  );

  DioException answered(int status, [Object? body]) => DioException(
    requestOptions: RequestOptions(path: '/x'),
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: RequestOptions(path: '/x'),
      statusCode: status,
      data: body,
    ),
  );

  test('no error at all reads as a generic failure', () {
    expect(shown(null), en.errorGeneric);
  });

  group('a request that never got an answer', () {
    final cases = {
      DioExceptionType.connectionTimeout: en.errorNetworkTimeout,
      DioExceptionType.sendTimeout: en.errorNetworkTimeout,
      DioExceptionType.receiveTimeout: en.errorNetworkTimeout,
      DioExceptionType.connectionError: en.errorConnectionError,
      DioExceptionType.cancel: en.errorRequestCancelled,
      DioExceptionType.unknown: en.errorNetworkGeneric,
      DioExceptionType.badCertificate: en.errorNetworkGeneric,
    };
    cases.forEach((type, message) {
      test(type.name, () => expect(shown(failed(type)), message));
    });
  });

  group('an HTTP error', () {
    test('400 shows the backend\'s reason, or a generic one', () {
      expect(
        shown(answered(400, {'message': 'Order already taken'})),
        'Order already taken',
      );
      expect(
        shown(answered(400, {'error': 'Order already taken'})),
        'Order already taken',
      );
      expect(shown(answered(400)), en.errorInvalidRequest);
    });

    test('422 shows the validation message, or a generic one', () {
      expect(
        shown(answered(422, {'message': 'The phone field is required.'})),
        'The phone field is required.',
      );
      expect(shown(answered(422)), en.errorValidation);
    });

    final byStatus = {
      401: en.errorSessionExpired,
      403: en.errorNoPermission,
      404: en.errorNotFound,
      409: en.errorConflict,
      429: en.errorTooManyRequests,
      500: en.errorServerUnavailable,
      502: en.errorServerUnavailable,
      503: en.errorServerUnavailable,
      504: en.errorServerUnavailable,
    };
    byStatus.forEach((status, message) {
      test('$status has its own sentence, whatever the body says', () {
        expect(
          shown(answered(status, {'message': 'SQLSTATE[HY000]'})),
          message,
        );
      });
    });

    test('any other status shows the backend\'s reason, or a generic one', () {
      expect(shown(answered(418, {'message': 'Teapot'})), 'Teapot');
      expect(shown(answered(418)), en.errorServerGeneric);
    });
  });

  group('the backend\'s own message', () {
    test('is shown as written', () {
      expect(
        shown(const ServerFailure('Order cannot be cancelled at this stage')),
        'Order cannot be cancelled at this stage',
      );
    });

    test(
      'is not mistaken for a database error because a word contains "db"',
      () {
        expect(
          shown(
            const ServerFailure('You already sent feedback for this order'),
          ),
          'You already sent feedback for this order',
          reason: '"feedback" contains "db"',
        );
      },
    );

    test('is not mistaken for maintenance because it says "down"', () {
      expect(
        shown(
          const ServerFailure('Your order was turned down by the restaurant'),
        ),
        'Your order was turned down by the restaurant',
      );
    });

    test('about the database or maintenance gets a clear sentence', () {
      expect(
        shown(const ServerFailure('Database connection lost')),
        en.errorDatabaseServer,
      );
      expect(
        shown(const ServerFailure('The server is down for maintenance')),
        en.errorServerMaintenance,
      );
      expect(shown(const ServerFailure('')), en.errorServerGeneric);
    });

    test('from a validation error is shown, it says what to fix', () {
      expect(
        shown(const ValidationFailure('The current password is incorrect.')),
        'The current password is incorrect.',
      );
      expect(
        shown(const ValidationFailure('The email has already been taken.')),
        'The email has already been taken.',
        reason: 'not "enter a valid email": the email is valid, just taken',
      );
      expect(shown(const ValidationFailure('')), en.errorValidation);
    });
  });

  group('failures', () {
    test('a network failure says why', () {
      expect(
        shown(const NetworkFailure('Connection timeout')),
        en.errorNetworkTimeout,
      );
      expect(
        shown(const NetworkFailure('Failed to connect to the server')),
        en.errorConnectionError,
      );
      expect(
        shown(const NetworkFailure('Network error')),
        en.errorNetworkGeneric,
      );
      expect(shown(const NetworkFailure('')), en.noInternetConnection);
    });

    test('a sign-in failure says why', () {
      expect(
        shown(const AuthFailure('Invalid email or password')),
        en.errorInvalidCredentials,
      );
      expect(shown(const AuthFailure('Token expired')), en.errorSessionExpired);
      expect(shown(const AuthFailure('Unauthorized')), en.errorAuthRequired);
      expect(shown(const AuthFailure('Forbidden')), en.errorNoPermission);
      expect(
        shown(const AuthFailure('Sign-in cancelled')),
        en.errorSignInCancelled,
      );
      expect(shown(const AuthFailure('')), en.errorAuthFailed);
    });

    test('storage failures on the phone', () {
      expect(shown(const DatabaseFailure('disk full')), en.errorDatabaseLocal);
      expect(shown(const CacheFailure()), en.errorCacheLoad);
    });

    test('exceptions read like the matching failures', () {
      expect(
        shown(const NetworkException(message: 'Receive timeout')),
        en.errorNetworkTimeout,
      );
      expect(
        shown(const ServerException(message: 'Restaurant is closed')),
        'Restaurant is closed',
      );
      expect(
        shown(const ValidationException(message: 'The name is too short.')),
        'The name is too short.',
      );
      expect(
        shown(const AuthException(message: 'Token expired')),
        en.errorSessionExpired,
      );
      expect(
        shown(const LocalDatabaseException(message: 'x')),
        en.errorDatabaseLocal,
      );
      expect(shown(const CacheException()), en.errorCacheLoad);
    });
  });

  group('technical details never reach the manager', () {
    test('a PHP error becomes a generic server error', () {
      expect(
        shown('Fatal error: Call to undefined method App\\Models\\Order::x()'),
        en.errorServerGeneric,
      );
    });

    test('an SQL error becomes a generic server error', () {
      const sql =
          'SQLSTATE[23000]: Integrity constraint violation: 1062 '
          "Duplicate entry '12' for key 'order_settlements'";
      expect(shown(sql), en.errorServerGeneric);
      expect(shown(const ServerFailure(sql)), en.errorServerGeneric);
    });

    test('a message carrying a stack trace becomes a generic server error', () {
      expect(
        shown('Server is busy Stack trace: #0 main (file.dart:1)'),
        en.errorServerGeneric,
      );
    });

    test('"Instance of" text becomes a generic error', () {
      expect(
        shown("Unexpected error: Instance of 'ServerException'"),
        en.errorGeneric,
      );
    });

    test('prefixes, HTML, URLs and IPs are removed', () {
      expect(shown('Exception: Restaurant is closed'), 'Restaurant is closed');
      expect(shown('<b>Restaurant</b> is closed'), 'Restaurant is closed');
      expect(
        shown('Could not reach https://api.example.dz/orders'),
        'Could not reach',
      );
      expect(shown('No answer from 192.168.1.10'), 'No answer from');
    });
  });

  group('the manager\'s language', () {
    for (final code in ['fr', 'ar']) {
      test('technical failures are explained in $code', () {
        final l10n = lookupAppLocalizations(Locale(code));

        expect(
          shown(failed(DioExceptionType.receiveTimeout), l10n),
          l10n.errorNetworkTimeout,
        );
        expect(l10n.errorNetworkTimeout, isNot(en.errorNetworkTimeout));
      });
    }
  });

  group('the app\'s own failures', () {
    // The app writes them in English when the server gave no answer or no
    // reason; they reached the screens as written (decision 15)
    final fr = lookupAppLocalizations(const Locale('fr'));

    test('are said in the user\'s language', () {
      expect(
        shown(
          'Request timeout. Please check your internet connection and try again.',
          fr,
        ),
        fr.errorNetworkTimeout,
      );
      expect(
        shown(
          'Backend request timed out. Please check your internet connection and try again.',
          fr,
        ),
        fr.errorNetworkTimeout,
      );
      expect(
        shown('Cannot connect to server at http://10.0.2.2:8000/api.', fr),
        fr.errorConnectionError,
      );
      expect(shown('Network connection error', fr), fr.errorConnectionError);
      expect(
        shown('Network error occurred: Connection reset by peer', fr),
        fr.errorNetworkGeneric,
      );
      expect(
        shown(const ServerFailure('Server error occurred'), fr),
        fr.errorServerGeneric,
      );
      expect(
        shown(
          const NetworkFailure(
            'Cannot connect to server. Please check your internet connection.',
          ),
          fr,
        ),
        fr.errorConnectionError,
      );
    });

    test('the server\'s own words stay as written, in any language', () {
      expect(
        shown('Code OTP invalide ou expiré.', fr),
        'Code OTP invalide ou expiré.',
      );
      expect(
        shown(const ServerFailure('رمز OTP غير صالح أو منتهي الصلاحية.'), fr),
        'رمز OTP غير صالح أو منتهي الصلاحية.',
      );
    });
  });

  group('which errors are shown at all', () {
    bool isShown(Object? error) => ErrorMessageMapper.shouldShowError(error);

    test('nothing to show', () => expect(isShown(null), isFalse));

    test('an error that only talks about cancelling is shown', () {
      expect(
        isShown(const ServerFailure('Order cannot be cancelled at this stage')),
        isTrue,
        reason: 'the manager tapped cancel and must learn why it failed',
      );
      expect(isShown('Your order was cancelled by the restaurant'), isTrue);
    });

    test('the manager closing Google sign-in stays silent', () {
      expect(
        isShown(const ServerException(message: 'Google sign-in was cancelled')),
        isFalse,
      );
      expect(
        isShown(const ServerFailure('Google sign-in was cancelled')),
        isFalse,
      );
      expect(isShown('Operation aborted by user'), isFalse);
    });

    test('a request the app cancelled stays silent; other failures show', () {
      expect(isShown(failed(DioExceptionType.cancel)), isFalse);
      expect(isShown(failed(DioExceptionType.connectionTimeout)), isTrue);
    });
  });
}
