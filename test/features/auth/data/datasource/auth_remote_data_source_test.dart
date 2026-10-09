import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fake_backend.dart';
import '../../../../helpers/fakes.dart';

/// The account API: registration, login, logout, the FCM token and the one-time
/// codes for email and password. What each call sends, what comes back, and
/// how every failure reaches the app.
void main() {
  late FakeBackend backend;
  late MockDeviceInfoService device;
  late AuthRemoteDataSource source;

  setUp(() {
    backend = FakeBackend();
    device = MockDeviceInfoService();
    when(() => device.getDeviceId()).thenAnswer((_) async => 'device-1');
    source = AuthRemoteDataSource(
      dio: testDio(backend),
      deviceInfoService: device,
    );
  });

  group('login', () {
    test('sends the email, password, app and device', () async {
      backend.reply('POST', '/auth/login', body: authJson());

      final answer = await source.login(
        email: 'karim@example.dz',
        password: 'Secret#2026',
      );

      // The device lets the server refuse a phone whose account was suspended
      expect(backend.last('POST', '/auth/login').json, {
        'email': 'karim@example.dz',
        'password': 'Secret#2026',
        'app_type': 'manager',
        'device_id': 'device-1',
      });
      expect(answer.token, '1|abcdef');
      expect(answer.message, 'Login successful');
    });

    test('a phone without a device id signs in without one', () async {
      when(() => device.getDeviceId()).thenAnswer((_) async => null);
      backend.reply('POST', '/auth/login', body: authJson());

      await source.login(email: 'karim@example.dz', password: 'Secret#2026');

      expect(
        backend.last('POST', '/auth/login').json,
        isNot(contains('device_id')),
      );
    });

    test('wrong credentials read as the backend says', () async {
      backend.reply(
        'POST',
        '/auth/login',
        status: 401,
        body: failure('Invalid credentials'),
      );

      await expectLater(
        source.login(email: 'karim@example.dz', password: 'wrong'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Invalid credentials')
              .having((e) => e.errorCode, 'errorCode', isNull),
        ),
      );
    });

    test('a refusal the server names keeps its code', () async {
      backend.reply(
        'POST',
        '/auth/login',
        status: 401,
        body: failure(
          'Identifiants invalides',
          errorCode: 'INVALID_CREDENTIALS',
        ),
      );

      await expectLater(
        source.login(email: 'yasmine@example.dz', password: 'wrong'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Identifiants invalides')
              .having((e) => e.errorCode, 'errorCode', 'INVALID_CREDENTIALS'),
        ),
      );
    });
  });

  test('logout revokes the given token on the server', () async {
    backend.reply('POST', '/auth/logout', body: ok(null));

    await source.logout(token: '1|abcdef');

    expect(
      backend.last('POST', '/auth/logout').headers['Authorization'],
      'Bearer 1|abcdef',
    );
  });

  test('the FCM token is sent as fcm_token', () async {
    backend.reply('POST', '/auth/update-fcm-token', body: ok(null));

    await source.updateFcmToken('fcm-token-1');

    expect(backend.last('POST', '/auth/update-fcm-token').json, {
      'fcm_token': 'fcm-token-1',
    });
  });

  group('one-time codes', () {
    test('a new email code reports when another may be asked', () async {
      backend.reply('POST', '/auth/email/resend', body: otpSentJson());

      final answer = await source.resendVerificationEmail();

      expect(answer.email, 'karim@example.dz');
      expect(answer.expiresIn, 600);
      expect(answer.resendCountdown, 60);
    });

    test('missing timings fall back to 10 minutes and 2 minutes', () async {
      backend.reply('POST', '/auth/email/resend', body: ok({}));

      final answer = await source.resendVerificationEmail();

      expect(answer.expiresIn, 600);
      expect(answer.resendCountdown, 120);
    });

    test('the email code is checked with the email', () async {
      backend.reply(
        'POST',
        '/auth/email/verify-email-otp',
        body: ok(userJson(), message: 'Email verified'),
      );

      final answer = await source.verifyEmailOtp(
        email: 'karim@example.dz',
        otp: '123456',
      );

      expect(backend.last('POST', '/auth/email/verify-email-otp').json, {
        'email': 'karim@example.dz',
        'otp': '123456',
      });
      expect(answer.message, 'Email verified');
    });

    test('a forgotten password sends a code to the email', () async {
      backend.reply(
        'POST',
        '/auth/password/forgot-password',
        body: otpSentJson(resendCountdown: 90),
      );

      final answer = await source.resendPasswordResetOtp('karim@example.dz');

      expect(backend.last('POST', '/auth/password/forgot-password').json, {
        'email': 'karim@example.dz',
      });
      expect(answer.resendCountdown, 90);
    });

    test('the reset code is checked, then the password reset', () async {
      backend
        ..reply(
          'POST',
          '/auth/password/verify-otp-unauthenticated',
          body: ok(null),
        )
        ..reply(
          'POST',
          '/auth/password/reset-password-unauthenticated',
          body: ok(null, message: 'Password reset'),
        );

      await source.verifyPasswordResetOtp(
        email: 'karim@example.dz',
        otp: '654321',
      );
      final message = await source.resetPassword(
        email: 'karim@example.dz',
        otp: '654321',
        password: 'NewSecret#1',
        passwordConfirmation: 'NewSecret#1',
      );

      expect(
        backend.last('POST', '/auth/password/verify-otp-unauthenticated').json,
        {'email': 'karim@example.dz', 'otp': '654321'},
      );
      expect(
        backend
            .last('POST', '/auth/password/reset-password-unauthenticated')
            .json,
        {
          'email': 'karim@example.dz',
          'otp': '654321',
          'password': 'NewSecret#1',
          'password_confirmation': 'NewSecret#1',
        },
      );
      expect(message, 'Password reset');
    });

    test('a signed-in manager resets with a code only', () async {
      backend
        ..reply(
          'POST',
          '/auth/password/resend-reset-otp-authenticated',
          body: otpSentJson(),
        )
        ..reply(
          'POST',
          '/auth/password/verify-otp-authenticated',
          body: ok(null),
        )
        ..reply(
          'POST',
          '/auth/password/reset-password-authenticated',
          body: {'success': true},
        );

      await source.sendPasswordResetOtpAuthenticated();
      await source.verifyPasswordResetOtpAuthenticated(otp: '111222');
      final message = await source.resetPasswordAuthenticated(
        otp: '111222',
        newPassword: 'NewSecret#1',
        newPasswordConfirmation: 'NewSecret#1',
      );

      expect(
        backend.last('POST', '/auth/password/verify-otp-authenticated').json,
        {'otp': '111222'},
      );
      expect(
        backend
            .last('POST', '/auth/password/reset-password-authenticated')
            .json,
        {
          'otp': '111222',
          'new_password': 'NewSecret#1',
          'new_password_confirmation': 'NewSecret#1',
        },
      );
      expect(message, 'Password reset successfully', reason: 'the default');
    });
  });

  group('every call, when it fails', () {
    final calls =
        <String, (String, Future<Object?> Function(AuthRemoteDataSource))>{
          'login': (
            '/auth/login',
            (s) => s.login(email: 'e@x.dz', password: 'p'),
          ),
          'logout': ('/auth/logout', (s) => s.logout(token: 't')),
          'updateFcmToken': (
            '/auth/update-fcm-token',
            (s) => s.updateFcmToken('f'),
          ),
          'resendVerificationEmail': (
            '/auth/email/resend',
            (s) => s.resendVerificationEmail(),
          ),
          'resendPasswordResetOtp': (
            '/auth/password/forgot-password',
            (s) => s.resendPasswordResetOtp('e@x.dz'),
          ),
          'sendPasswordResetOtpAuthenticated': (
            '/auth/password/resend-reset-otp-authenticated',
            (s) => s.sendPasswordResetOtpAuthenticated(),
          ),
          'verifyEmailOtp': (
            '/auth/email/verify-email-otp',
            (s) => s.verifyEmailOtp(email: 'e@x.dz', otp: '1'),
          ),
          'verifyPasswordResetOtp': (
            '/auth/password/verify-otp-unauthenticated',
            (s) => s.verifyPasswordResetOtp(email: 'e@x.dz', otp: '1'),
          ),
          'resetPassword': (
            '/auth/password/reset-password-unauthenticated',
            (s) => s.resetPassword(
              email: 'e@x.dz',
              otp: '1',
              password: 'p',
              passwordConfirmation: 'p',
            ),
          ),
          'verifyPasswordResetOtpAuthenticated': (
            '/auth/password/verify-otp-authenticated',
            (s) => s.verifyPasswordResetOtpAuthenticated(otp: '1'),
          ),
          'resetPasswordAuthenticated': (
            '/auth/password/reset-password-authenticated',
            (s) => s.resetPasswordAuthenticated(
              otp: '1',
              newPassword: 'p',
              newPasswordConfirmation: 'p',
            ),
          ),
        };

    calls.forEach((name, call) {
      final (path, run) = call;

      group(name, () {
        test('a timeout is a network problem', () async {
          backend.fail('POST', path, DioExceptionType.receiveTimeout);

          await expectLater(
            run(source),
            throwsA(
              isA<NetworkException>().having(
                (e) => e.message,
                'message',
                contains('timeout'),
              ),
            ),
          );
        });

        test('no connection is a network problem', () async {
          backend.fail('POST', path, DioExceptionType.connectionError);

          await expectLater(
            run(source),
            throwsA(
              isA<NetworkException>().having(
                (e) => e.message,
                'message',
                contains('Cannot connect'),
              ),
            ),
          );
        });

        test('an HTML error page is a server error, not a crash', () async {
          backend.reply('POST', path, status: 502, body: htmlErrorPage);

          await expectLater(run(source), throwsA(isA<ServerException>()));
        });

        test('the backend\'s message is kept', () async {
          backend.reply(
            'POST',
            path,
            status: 429,
            body: failure('Too many attempts. Try again in a minute.'),
          );

          await expectLater(
            run(source),
            throwsA(
              isA<ServerException>().having(
                (e) => e.message,
                'message',
                'Too many attempts. Try again in a minute.',
              ),
            ),
          );
        });
      });
    });
  });
}
