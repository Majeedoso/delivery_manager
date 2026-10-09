import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/models/auth_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_password_reset_otp_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_verification_email_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/data/models/verify_email_otp_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/api_json.dart';

/// How the account answers of the backend become app objects, including the
/// lenient parsing of ids and the defaults when fields are missing.
void main() {
  group('UserModel', () {
    test('reads every field the backend sends', () {
      final user = UserModel.fromJson(userJson());

      expect(user.id, 7);
      expect(user.name, 'Karim Haddad');
      expect(user.email, 'karim@example.dz');
      expect(user.phone, '0550123456');
      expect(user.role, UserRole.manager);
      expect(user.status, 'active');
      expect(user.emailVerifiedAt, DateTime.utc(2026, 9, 1, 10));
      expect(user.hasPassword, isTrue);
    });

    test('an id sent as text is read as a number', () {
      expect(UserModel.fromJson({...userJson(), 'id': '12'}).id, 12);
      expect(UserModel.fromJson({...userJson(), 'id': 'x'}).id, 0);
    });

    test('each role name is recognised', () {
      for (final role in UserRole.values) {
        expect(UserModel.fromJson(userJson(role: role.name)).role, role);
      }
    });

    test('missing fields have safe defaults', () {
      final user = UserModel.fromJson({'id': 1});

      expect(user.name, '');
      expect(user.phone, '');
      expect(user.emailVerifiedAt, isNull);
      expect(user.hasPassword, isFalse);
    });

    test('round-trips through JSON', () {
      final user = UserModel.fromJson({...userJson(), 'token': '1|abc'});

      expect(UserModel.fromJson(user.toJson()), user);
    });
  });

  group('AuthResponseModel', () {
    test('reads the user, token and message', () {
      final answer = AuthResponseModel.fromJson(authJson(token: '5|t'));

      expect(answer.user.email, 'karim@example.dz');
      expect(answer.token, '5|t');
      expect(answer.message, 'Login successful');
    });

    test('an empty answer gives an empty token, not a crash', () {
      final answer = AuthResponseModel.fromJson({});

      expect(answer.token, '');
      expect(answer.message, 'Success');
    });
  });

  group('code answers', () {
    test('email and password codes read the same timings', () {
      final email = ResendVerificationEmailResponseModel.fromJson(
        otpSentJson(expiresIn: 300, resendCountdown: 45),
      );
      final password = ResendPasswordResetOtpResponseModel.fromJson(
        otpSentJson(expiresIn: 300, resendCountdown: 45),
      );

      expect([email.expiresIn, email.resendCountdown], [300, 45]);
      expect([password.expiresIn, password.resendCountdown], [300, 45]);
      expect(email.toJson()['email'], 'karim@example.dz');
    });

    test('a verified email keeps the token the app already had', () {
      final answer = VerifyEmailOtpResponseModel.fromJson(
        ok(userJson(), message: 'Email verified'),
        token: '1|kept',
      );

      expect(answer.user.token, '1|kept');
      expect(answer.message, 'Email verified');
    });
  });
}
