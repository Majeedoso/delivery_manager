import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/data/models/auth_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_password_reset_otp_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_verification_email_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/clear_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/clear_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/get_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/google_sign_out_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/reset_password_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/send_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/validate_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/api_json.dart';
import '../../../helpers/fakes.dart';
import '../../../helpers/usecases.dart';

/// The account use cases. All but CheckAuthStatus only forward to a
/// repository; CheckAuthStatus decides at start-up whether the saved login
/// still counts.
void main() {
  late MockAuthRepository auth;
  late MockTokenRepository tokens;
  late MockSecureStorageRepository remember;

  final user = UserModel.fromJson(userJson());
  final signedIn = AuthResponseModel.fromJson(authJson());
  const codeSent = ResendPasswordResetOtpResponseModel(
    email: 'karim@example.dz',
    expiresIn: 600,
    resendCountdown: 60,
  );
  const none = NoParameters();

  setUp(() {
    auth = MockAuthRepository();
    tokens = MockTokenRepository();
    remember = MockSecureStorageRepository();
  });

  group('CheckAuthStatusUseCase', () {
    late CheckAuthStatusUseCase check;

    setUp(() => check = CheckAuthStatusUseCase(tokens));

    void storedToken(String? token) =>
        when(() => tokens.getToken()).thenAnswer((_) async => Right(token));

    void serverSays(Either<Failure, bool> answer) =>
        when(() => tokens.validateToken(any())).thenAnswer((_) async => answer);

    test('no saved token: signed out, without asking the server', () async {
      storedToken(null);

      expect(await check(none), const Right<Failure, bool>(false));
      verifyNever(() => tokens.validateToken(any()));
    });

    test('an empty token counts as none', () async {
      storedToken('');

      expect(await check(none), const Right<Failure, bool>(false));
    });

    test('the server confirming the token: signed in', () async {
      storedToken('1|abc');
      serverSays(const Right(true));

      expect(await check(none), const Right<Failure, bool>(true));
      verify(() => tokens.validateToken('1|abc')).called(1);
    });

    test('the server rejecting the token (401): signed out', () async {
      storedToken('1|abc');
      serverSays(const Right(false));

      expect(await check(none), const Right<Failure, bool>(false));
    });

    test('the server unreachable: the saved login is kept', () async {
      storedToken('1|abc');
      serverSays(const Left(NetworkFailure('Cannot connect to server')));

      expect(
        await check(none),
        const Right<Failure, bool>(true),
        reason: 'a network blip must not sign the manager out',
      );
    });

    test('a server error: the saved login is kept', () async {
      storedToken('1|abc');
      serverSays(const Left(ServerFailure('Token validation failed: 500')));

      expect(await check(none), const Right<Failure, bool>(true));
    });

    test('the saved token can\'t be read: the failure is reported', () async {
      when(
        () => tokens.getToken(),
      ).thenAnswer((_) async => const Left(CacheFailure('keystore')));

      expect(
        await check(none),
        const Left<Failure, bool>(CacheFailure('keystore')),
      );
    });
  });

  group('forwarding use cases', () {
    test('LoginUseCase', () async {
      await expectPassThrough(
        stub: (answer) => when(
          () => auth.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => LoginUseCase(auth)(
          const LoginParameters(email: 'karim@example.dz', password: 'pw'),
        ),
        value: signedIn,
        verifyForwarded: () => verify(
          () => auth.login(email: 'karim@example.dz', password: 'pw'),
        ).called(1),
      );
    });

    test('LogoutUseCase', () async {
      await expectPassThrough<void>(
        stub: (answer) =>
            when(() => auth.logout()).thenAnswer((_) async => answer),
        run: () => LogoutUseCase(auth)(none),
        value: null,
        verifyForwarded: () => verify(() => auth.logout()).called(1),
      );
    });

    test('GetCurrentUserUseCase', () async {
      await expectPassThrough(
        stub: (answer) =>
            when(() => auth.getCurrentUser()).thenAnswer((_) async => answer),
        run: () => GetCurrentUserUseCase(auth)(none),
        value: user,
        verifyForwarded: () => verify(() => auth.getCurrentUser()).called(1),
      );
    });

    test(
      'GoogleSignInUseCase / GoogleSignOutUseCase',
      () async {
        await expectPassThrough(
          stub: (answer) =>
              when(() => auth.googleSignIn()).thenAnswer((_) async => answer),
          run: () => GoogleSignInUseCase(auth)(none),
          value: user,
          verifyForwarded: () => verify(() => auth.googleSignIn()).called(1),
        );
        await expectPassThrough<void>(
          stub: (answer) =>
              when(() => auth.googleSignOut()).thenAnswer((_) async => answer),
          run: () => GoogleSignOutUseCase(auth)(none),
          value: null,
          verifyForwarded: () => verify(() => auth.googleSignOut()).called(1),
        );
      },
    );

    test('ResendVerificationEmailUseCase', () async {
      const sent = ResendVerificationEmailResponseModel(
        email: 'karim@example.dz',
        expiresIn: 600,
        resendCountdown: 60,
      );
      await expectPassThrough(
        stub: (answer) => when(
          () => auth.resendVerificationEmail(),
        ).thenAnswer((_) async => answer),
        run: () => ResendVerificationEmailUseCase(auth)(none),
        value: sent,
        verifyForwarded: () =>
            verify(() => auth.resendVerificationEmail()).called(1),
      );
    });

    test('ResendPasswordResetOtpUseCase', () async {
      await expectPassThrough(
        stub: (answer) => when(
          () => auth.resendPasswordResetOtp(any()),
        ).thenAnswer((_) async => answer),
        run: () => ResendPasswordResetOtpUseCase(auth)(
          ResendPasswordResetOtpParameters(email: 'karim@example.dz'),
        ),
        value: codeSent,
        verifyForwarded: () => verify(
          () => auth.resendPasswordResetOtp('karim@example.dz'),
        ).called(1),
      );
    });

    test('SendPasswordResetOtpAuthenticatedUseCase', () async {
      await expectPassThrough(
        stub: (answer) => when(
          () => auth.sendPasswordResetOtpAuthenticated(),
        ).thenAnswer((_) async => answer),
        run: () => SendPasswordResetOtpAuthenticatedUseCase(auth)(none),
        value: codeSent,
        verifyForwarded: () =>
            verify(() => auth.sendPasswordResetOtpAuthenticated()).called(1),
      );
    });

    test('VerifyPasswordResetOtpUseCase', () async {
      await expectPassThrough<void>(
        stub: (answer) => when(
          () => auth.verifyPasswordResetOtp(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => VerifyPasswordResetOtpUseCase(auth)(
          const VerifyPasswordResetOtpParameters(
            email: 'karim@example.dz',
            otp: '123456',
          ),
        ),
        value: null,
        verifyForwarded: () => verify(
          () => auth.verifyPasswordResetOtp(
            email: 'karim@example.dz',
            otp: '123456',
          ),
        ).called(1),
      );
    });

    test('ResetPasswordUseCase', () async {
      await expectPassThrough(
        stub: (answer) => when(
          () => auth.resetPassword(
            email: any(named: 'email'),
            otp: any(named: 'otp'),
            password: any(named: 'password'),
            passwordConfirmation: any(named: 'passwordConfirmation'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => ResetPasswordUseCase(auth)(
          const ResetPasswordParameters(
            email: 'karim@example.dz',
            otp: '123456',
            password: 'New#1',
            passwordConfirmation: 'New#1',
          ),
        ),
        value: 'Password reset',
        verifyForwarded: () => verify(
          () => auth.resetPassword(
            email: 'karim@example.dz',
            otp: '123456',
            password: 'New#1',
            passwordConfirmation: 'New#1',
          ),
        ).called(1),
      );
    });

    test('VerifyPasswordResetOtpAuthenticatedUseCase', () async {
      await expectPassThrough<void>(
        stub: (answer) => when(
          () =>
              auth.verifyPasswordResetOtpAuthenticated(otp: any(named: 'otp')),
        ).thenAnswer((_) async => answer),
        run: () => VerifyPasswordResetOtpAuthenticatedUseCase(auth)(
          const VerifyPasswordResetOtpAuthenticatedParameters(otp: '123456'),
        ),
        value: null,
        verifyForwarded: () => verify(
          () => auth.verifyPasswordResetOtpAuthenticated(otp: '123456'),
        ).called(1),
      );
    });

    test('ResetPasswordAuthenticatedUseCase', () async {
      await expectPassThrough(
        stub: (answer) => when(
          () => auth.resetPasswordAuthenticated(
            otp: any(named: 'otp'),
            newPassword: any(named: 'newPassword'),
            newPasswordConfirmation: any(named: 'newPasswordConfirmation'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => ResetPasswordAuthenticatedUseCase(auth)(
          const ResetPasswordAuthenticatedParameters(
            otp: '123456',
            newPassword: 'New#1',
            newPasswordConfirmation: 'New#1',
          ),
        ),
        value: 'Password changed',
        verifyForwarded: () => verify(
          () => auth.resetPasswordAuthenticated(
            otp: '123456',
            newPassword: 'New#1',
            newPasswordConfirmation: 'New#1',
          ),
        ).called(1),
      );
    });

    test('the token use cases', () async {
      await expectPassThrough(
        stub: (answer) =>
            when(() => tokens.saveToken(any())).thenAnswer((_) async => answer),
        run: () =>
            SaveTokenUseCase(tokens)(const SaveTokenParameters(token: '1|abc')),
        value: true,
        verifyForwarded: () =>
            verify(() => tokens.saveToken('1|abc')).called(1),
      );
      await expectPassThrough<String?>(
        stub: (answer) =>
            when(() => tokens.getToken()).thenAnswer((_) async => answer),
        run: () => GetTokenUseCase(tokens)(none),
        value: '1|abc',
        verifyForwarded: () => verify(() => tokens.getToken()).called(1),
      );
      await expectPassThrough(
        stub: (answer) =>
            when(() => tokens.clearToken()).thenAnswer((_) async => answer),
        run: () => ClearTokenUseCase(tokens)(none),
        value: true,
        verifyForwarded: () => verify(() => tokens.clearToken()).called(1),
      );
      await expectPassThrough(
        stub: (answer) => when(
          () => tokens.validateToken(any()),
        ).thenAnswer((_) async => answer),
        run: () => ValidateTokenUseCase(tokens)(
          const ValidateTokenParameters(token: '1|abc'),
        ),
        value: true,
        verifyForwarded: () =>
            verify(() => tokens.validateToken('1|abc')).called(1),
      );
    });

    test('the remember-me use cases', () async {
      await expectPassThrough(
        stub: (answer) => when(
          () => remember.saveCredentials(
            email: any(named: 'email'),
            password: any(named: 'password'),
            rememberMe: any(named: 'rememberMe'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => SaveCredentialsUseCase(remember)(
          const SaveCredentialsParameters(
            email: 'karim@example.dz',
            password: 'pw',
            rememberMe: true,
          ),
        ),
        value: true,
        verifyForwarded: () => verify(
          () => remember.saveCredentials(
            email: 'karim@example.dz',
            password: 'pw',
            rememberMe: true,
          ),
        ).called(1),
      );
      await expectPassThrough<Map<String, String?>>(
        stub: (answer) => when(
          () => remember.loadCredentials(),
        ).thenAnswer((_) async => answer),
        run: () => LoadCredentialsUseCase(remember)(none),
        value: {'email': 'karim@example.dz', 'rememberMe': 'true'},
        verifyForwarded: () =>
            verify(() => remember.loadCredentials()).called(1),
      );
      await expectPassThrough(
        stub: (answer) => when(
          () => remember.clearCredentials(),
        ).thenAnswer((_) async => answer),
        run: () => ClearCredentialsUseCase(remember)(none),
        value: true,
        verifyForwarded: () =>
            verify(() => remember.clearCredentials()).called(1),
      );
    });
  });
}
