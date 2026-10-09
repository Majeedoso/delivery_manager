import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/services/notification_service.dart';
import 'package:delivery_manager/core/utils/app_timeouts.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/models/auth_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_password_reset_otp_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_verification_email_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_token_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fake_backend.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';

/// AuthBloc holds who is signed in. Every flow (password, Google, the codes
/// for email and password) goes loading → loaded or error, a sign-in keeps
/// the token and registers the phone for pushes, and a logout always ends
/// signed out, whatever the server does.
void main() {
  late MockLoginUseCase login;
  late MockLogoutUseCase logout;
  late MockGetCurrentUserUseCase currentUser;
  late MockGoogleSignInUseCase googleSignIn;
  late MockGoogleSignOutUseCase googleSignOut;
  late MockSaveTokenUseCase saveToken;
  late MockCheckAuthStatusUseCase checkAuth;
  late MockClearTokenUseCase clearToken;
  late MockResendVerificationEmailUseCase resendEmail;
  late MockResendPasswordResetOtpUseCase resendReset;
  late MockVerifyPasswordResetOtpUseCase verifyReset;
  late MockResetPasswordUseCase resetPassword;
  late MockSendPasswordResetOtpAuthenticatedUseCase sendResetSignedIn;
  late MockVerifyPasswordResetOtpAuthenticatedUseCase verifyResetSignedIn;
  late MockResetPasswordAuthenticatedUseCase resetPasswordSignedIn;
  late MockLoadCredentialsUseCase loadCredentials;
  late MockSaveCredentialsUseCase saveCredentials;
  late MockAuthRemoteDataSource pushApi;

  final user = UserModel.fromJson(userJson());
  final signedIn = AuthResponseModel.fromJson(authJson(token: '1|abcdef'));
  const codeSent = ResendPasswordResetOtpResponseModel(
    email: 'karim@example.dz',
    expiresIn: 600,
    resendCountdown: 60,
  );
  const emailSent = ResendVerificationEmailResponseModel(
    email: 'karim@example.dz',
    expiresIn: 600,
    resendCountdown: 45,
  );
  const fcmToken = 'fcm-device-1:APA91bHPRgkF3JUikC4ENAHEeMrd41Zxv3hVZjC9KtT8';

  setUpAll(registerFallbacks);

  setUp(() {
    login = MockLoginUseCase();
    logout = MockLogoutUseCase();
    currentUser = MockGetCurrentUserUseCase();
    googleSignIn = MockGoogleSignInUseCase();
    googleSignOut = MockGoogleSignOutUseCase();
    saveToken = MockSaveTokenUseCase();
    checkAuth = MockCheckAuthStatusUseCase();
    clearToken = MockClearTokenUseCase();
    resendEmail = MockResendVerificationEmailUseCase();
    resendReset = MockResendPasswordResetOtpUseCase();
    verifyReset = MockVerifyPasswordResetOtpUseCase();
    resetPassword = MockResetPasswordUseCase();
    sendResetSignedIn = MockSendPasswordResetOtpAuthenticatedUseCase();
    verifyResetSignedIn = MockVerifyPasswordResetOtpAuthenticatedUseCase();
    resetPasswordSignedIn = MockResetPasswordAuthenticatedUseCase();
    loadCredentials = MockLoadCredentialsUseCase();
    saveCredentials = MockSaveCredentialsUseCase();

    when(() => login(any())).thenAnswer((_) async => Right(signedIn));
    when(() => logout(any())).thenAnswer((_) async => const Right(null));
    when(() => currentUser(any())).thenAnswer((_) async => Right(user));
    when(() => googleSignIn(any())).thenAnswer((_) async => Right(user));
    when(() => googleSignOut(any())).thenAnswer((_) async => const Right(null));
    when(() => saveToken(any())).thenAnswer((_) async => const Right(true));
    when(() => checkAuth(any())).thenAnswer((_) async => const Right(false));
    when(() => clearToken(any())).thenAnswer((_) async => const Right(true));
    when(
      () => resendEmail(any()),
    ).thenAnswer((_) async => const Right(emailSent));
    when(
      () => resendReset(any()),
    ).thenAnswer((_) async => const Right(codeSent));
    when(() => verifyReset(any())).thenAnswer((_) async => const Right(null));
    when(
      () => resetPassword(any()),
    ).thenAnswer((_) async => const Right('Password reset'));
    when(
      () => sendResetSignedIn(any()),
    ).thenAnswer((_) async => const Right(codeSent));
    when(
      () => verifyResetSignedIn(any()),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => resetPasswordSignedIn(any()),
    ).thenAnswer((_) async => const Right('Password changed'));
    when(
      () => loadCredentials(any()),
    ).thenAnswer((_) async => const Right({'email': null, 'rememberMe': null}));
    when(
      () => saveCredentials(any()),
    ).thenAnswer((_) async => const Right(true));

    // The push token goes out through the real NotificationService.
    final tokens = MockTokenRepository();
    pushApi = MockAuthRemoteDataSource();
    when(
      () => tokens.getToken(),
    ).thenAnswer((_) async => const Right('1|abcdef'));
    when(() => pushApi.updateFcmToken(any())).thenAnswer((_) async {});
    registerService<BaseTokenRepository>(tokens);
    registerService<BaseAuthRemoteDataSource>(pushApi);
    NotificationService.fetchFcmToken = () async => fcmToken;
  });

  AuthBloc build() => AuthBloc(
    loginUseCase: login,
    logoutUseCase: logout,
    getCurrentUserUseCase: currentUser,
    googleSignInUseCase: googleSignIn,
    googleSignOutUseCase: googleSignOut,
    saveTokenUseCase: saveToken,
    checkAuthStatusUseCase: checkAuth,
    clearTokenUseCase: clearToken,
    resendVerificationEmailUseCase: resendEmail,
    resendPasswordResetOtpUseCase: resendReset,
    verifyPasswordResetOtpUseCase: verifyReset,
    resetPasswordUseCase: resetPassword,
    sendPasswordResetOtpAuthenticatedUseCase: sendResetSignedIn,
    verifyPasswordResetOtpAuthenticatedUseCase: verifyResetSignedIn,
    resetPasswordAuthenticatedUseCase: resetPasswordSignedIn,
    loadCredentialsUseCase: loadCredentials,
    saveCredentialsUseCase: saveCredentials,
    logger: silentLogger(),
  );

  const loading = AuthState(requestState: RequestState.loading);
  const failure = ServerFailure('Invalid credentials');
  const loggedOut = AuthState(
    requestState: RequestState.loaded,
    isAuthenticated: false,
    message: 'Logged out successfully',
  );

  group('login', () {
    blocTest<AuthBloc, AuthState>(
      'signs in, keeps the token and registers the phone for pushes',
      build: build,
      act: (bloc) => bloc.add(
        const LoginEvent(email: 'karim@example.dz', password: 'Secret#2026'),
      ),
      expect: () => [
        loading,
        AuthState(
          requestState: RequestState.loaded,
          user: signedIn.user,
          message: 'Login successful',
          isAuthenticated: true,
        ),
      ],
      verify: (_) {
        final sent = verify(() => login(captureAny())).captured.single;
        expect(sent.email, 'karim@example.dz');
        verify(
          () => saveToken(
            any(
              that: isA<SaveTokenParameters>().having(
                (p) => p.token,
                'token',
                '1|abcdef',
              ),
            ),
          ),
        ).called(1);
        verify(() => pushApi.updateFcmToken(fcmToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a refusal shows the reason and stays signed out',
      setUp: () =>
          when(() => login(any())).thenAnswer((_) async => const Left(failure)),
      build: build,
      act: (bloc) =>
          bloc.add(const LoginEvent(email: 'e@x.dz', password: 'wrong')),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.error,
          message: 'Invalid credentials',
        ),
      ],
      verify: (_) => verifyNever(() => saveToken(any())),
    );

    blocTest<AuthBloc, AuthState>(
      'a refusal the server names keeps its code, in whatever language',
      setUp: () => when(() => login(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure(
            'Identifiants invalides',
            errorCode: 'INVALID_CREDENTIALS',
          ),
        ),
      ),
      build: build,
      act: (bloc) =>
          bloc.add(const LoginEvent(email: 'e@x.dz', password: 'wrong')),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.error,
          message: 'Identifiants invalides',
          errorCode: 'INVALID_CREDENTIALS',
        ),
      ],
    );

    test('the code belongs to one state: the next one has none', () {
      const refused = AuthState(
        requestState: RequestState.error,
        message: 'Identifiants invalides',
        errorCode: 'INVALID_CREDENTIALS',
      );

      final next = refused.copyWith(requestState: RequestState.loading);

      expect(next.errorCode, isNull);
      expect(next.message, 'Identifiants invalides');
      expect(refused, isNot(refused.copyWith()));
    });
  });

  group('logout', () {
    blocTest<AuthBloc, AuthState>(
      'ends signed out and forgets the token',
      build: build,
      seed: () => AuthState(
        requestState: RequestState.loaded,
        user: user,
        isAuthenticated: true,
      ),
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        AuthState(
          requestState: RequestState.loading,
          user: user,
          isAuthenticated: true,
        ),
        loggedOut,
      ],
      verify: (_) => verify(() => clearToken(any())).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'a server failure still signs out',
      setUp: () => when(
        () => logout(any()),
      ).thenAnswer((_) async => const Left(failure)),
      build: build,
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [loading, loggedOut],
      verify: (_) => verify(() => clearToken(any())).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'an unexpected error still signs out',
      setUp: () => when(() => logout(any())).thenThrow(StateError('boom')),
      build: build,
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [loading, loggedOut],
    );

    test('a logout that hangs signs out after 5 seconds', () {
      fakeAsync((async) {
        when(
          () => logout(any()),
        ).thenAnswer((_) => Completer<Either<Failure, void>>().future);
        final bloc = build();
        final states = <AuthState>[];
        bloc.stream.listen(states.add);

        bloc.add(LogoutEvent());
        async.elapse(AppTimeouts.logout - const Duration(milliseconds: 1));
        expect(states, [loading]);

        async.elapse(const Duration(milliseconds: 1));
        expect(states.last, loggedOut);
        verify(() => clearToken(any())).called(1);
        bloc.close();
        async.flushMicrotasks();
      });
    });
  });

  group('the start-up check', () {
    blocTest<AuthBloc, AuthState>(
      'no valid login: signed out',
      build: build,
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        loading,
        const AuthState(requestState: RequestState.loaded),
      ],
      verify: (_) => verifyNever(() => currentUser(any())),
    );

    blocTest<AuthBloc, AuthState>(
      'a valid login: the user is loaded and the push token synced',
      setUp: () => when(
        () => checkAuth(any()),
      ).thenAnswer((_) async => const Right(true)),
      build: build,
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        loading,
        AuthState(
          requestState: RequestState.loaded,
          user: user,
          isAuthenticated: true,
        ),
      ],
      verify: (_) => verify(() => pushApi.updateFcmToken(fcmToken)).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'the saved login can\'t be read: an error, signed out',
      setUp: () => when(
        () => checkAuth(any()),
      ).thenAnswer((_) async => const Left(CacheFailure('keystore'))),
      build: build,
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        loading,
        const AuthState(requestState: RequestState.error, message: 'keystore'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'the user can\'t be loaded: an error',
      setUp: () {
        when(() => checkAuth(any())).thenAnswer((_) async => const Right(true));
        when(
          () => currentUser(any()),
        ).thenAnswer((_) async => const Left(failure));
      },
      build: build,
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.error,
          message: 'Invalid credentials',
        ),
      ],
    );

    group('with the user already in memory (account status refresh)', () {
      late FakeBackend backend;
      final inMemory = UserModel.fromJson({
        ...userJson(status: 'pending_approval'),
        'token': '1|mem',
      });

      setUp(() {
        backend = FakeBackend();
        registerService<Dio>(testDio(backend));
      });

      blocTest<AuthBloc, AuthState>(
        'refreshes from the server with that token',
        setUp: () => backend.reply(
          'GET',
          '/auth/user',
          body: ok(userJson(status: 'active')),
        ),
        build: build,
        seed: () =>
            AuthState(requestState: RequestState.loaded, user: inMemory),
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        // A real request through the fake backend: 10 ms was too short on a
        // busy machine
        wait: const Duration(milliseconds: 300),
        skip: 1,
        expect: () => [
          isA<AuthState>()
              .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue)
              .having((s) => s.user?.status, 'status', 'active')
              .having((s) => s.user?.token, 'token', '1|mem'),
        ],
        verify: (_) => expect(
          backend.last('GET', '/auth/user').headers['Authorization'],
          'Bearer 1|mem',
        ),
      );

      blocTest<AuthBloc, AuthState>(
        'a failed refresh keeps the user and reports the error',
        setUp: () =>
            backend.fail('GET', '/auth/user', DioExceptionType.connectionError),
        build: build,
        seed: () =>
            AuthState(requestState: RequestState.loaded, user: inMemory),
        act: (bloc) => bloc.add(CheckAuthStatusEvent()),
        // A real request through the fake backend: 10 ms was too short on a
        // busy machine
        wait: const Duration(milliseconds: 300),
        skip: 1,
        expect: () => [
          isA<AuthState>()
              .having((s) => s.requestState, 'requestState', RequestState.error)
              .having((s) => s.user, 'user', inMemory)
              .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue),
        ],
      );
    });
  });

  group('Google', () {
    blocTest<AuthBloc, AuthState>(
      'signing in loads the user and syncs the push token',
      build: build,
      act: (bloc) => bloc.add(GoogleSignInEvent()),
      expect: () => [
        loading,
        AuthState(
          requestState: RequestState.loaded,
          user: user,
          message: 'Signed in with Google successfully',
          isAuthenticated: true,
        ),
      ],
      verify: (_) => verify(() => pushApi.updateFcmToken(fcmToken)).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'closing the account picker is quiet',
      setUp: () => when(() => googleSignIn(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Google sign-in was cancelled')),
      ),
      build: build,
      act: (bloc) => bloc.add(GoogleSignInEvent()),
      expect: () => [
        loading,
        const AuthState(requestState: RequestState.loaded),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'any other failure is an error',
      setUp: () => when(() => googleSignIn(any())).thenAnswer(
        (_) async => const Left(NetworkFailure('Cannot connect to server')),
      ),
      build: build,
      act: (bloc) => bloc.add(GoogleSignInEvent()),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.error,
          message: 'Cannot connect to server',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'an account of another app keeps the server\'s code, in whatever language',
      setUp: () => when(() => googleSignIn(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure(
            'هذا الحساب حساب سائق. استخدم تطبيق السائق لتسجيل الدخول.',
            errorCode: 'ROLE_MISMATCH',
          ),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(GoogleSignInEvent()),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.error,
          message: 'هذا الحساب حساب سائق. استخدم تطبيق السائق لتسجيل الدخول.',
          errorCode: 'ROLE_MISMATCH',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'signing out ends signed out',
      build: build,
      act: (bloc) => bloc.add(GoogleSignOutEvent()),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.loaded,
          message: 'Signed out from Google successfully',
        ),
      ],
    );
  });

  group('codes and passwords', () {
    blocTest<AuthBloc, AuthState>(
      'a new email code starts its resend countdown',
      build: build,
      act: (bloc) => bloc.add(ResendVerificationEmailEvent()),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.loaded,
          message: 'verificationEmailSent',
          resendCountdown: 45,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a forgotten password sends a code and starts the countdown',
      build: build,
      act: (bloc) => bloc.add(
        const ResendPasswordResetOtpEvent(email: 'karim@example.dz'),
      ),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.loaded,
          message:
              'Password reset OTP sent successfully. Please check your email.',
          resendCountdown: 60,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a valid reset code lets the password be reset',
      build: build,
      act: (bloc) => bloc.add(
        const VerifyPasswordResetOtpEvent(email: 'e@x.dz', otp: '123456'),
      ),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.loaded,
          message:
              'OTP verified successfully. You can now reset your password.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a reset updates the remembered email when remember me is on',
      setUp: () => when(() => loadCredentials(any())).thenAnswer(
        (_) async =>
            const Right({'email': 'old@example.dz', 'rememberMe': 'true'}),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const ResetPasswordEvent(
          email: 'karim@example.dz',
          otp: '123456',
          password: 'New#1',
          passwordConfirmation: 'New#1',
        ),
      ),
      expect: () => [
        loading,
        // The bloc's own words: the page waits for them, and the server's
        // sentence ('Password reset' here) is in the app's language
        const AuthState(
          requestState: RequestState.loaded,
          message: 'Password reset successfully',
        ),
      ],
      verify: (_) {
        final saved =
            verify(() => saveCredentials(captureAny())).captured.single
                as SaveCredentialsParameters;
        expect(saved.email, 'karim@example.dz');
        expect(saved.rememberMe, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a reset leaves remember me alone when it is off',
      build: build,
      act: (bloc) => bloc.add(
        const ResetPasswordEvent(
          email: 'e@x.dz',
          otp: '1',
          password: 'p',
          passwordConfirmation: 'p',
        ),
      ),
      skip: 2,
      verify: (_) => verifyNever(() => saveCredentials(any())),
    );

    blocTest<AuthBloc, AuthState>(
      'a wrong code shows the reason',
      setUp: () => when(() => verifyReset(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Invalid or expired code')),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const VerifyPasswordResetOtpEvent(email: 'e@x.dz', otp: '000000'),
      ),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.error,
          message: 'Invalid or expired code',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'signed in: a reset code is sent with its countdown',
      build: build,
      act: (bloc) => bloc.add(const SendPasswordResetOtpAuthenticatedEvent()),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.loaded,
          message:
              'Password reset OTP sent successfully. Please check your email.',
          resendCountdown: 60,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'signed in: the code is checked',
      build: build,
      act: (bloc) => bloc.add(
        const VerifyPasswordResetOtpAuthenticatedEvent(otp: '123456'),
      ),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.loaded,
          message:
              'OTP verified successfully. You can now reset your password.',
        ),
      ],
      verify: (_) => verify(() => verifyResetSignedIn(any())).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'signed in: the new password is set and remembered',
      setUp: () => when(() => loadCredentials(any())).thenAnswer(
        (_) async =>
            const Right({'email': 'karim@example.dz', 'rememberMe': 'true'}),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const ResetPasswordAuthenticatedEvent(
          otp: '123456',
          newPassword: 'New#1',
          newPasswordConfirmation: 'New#1',
        ),
      ),
      expect: () => [
        loading,
        const AuthState(
          requestState: RequestState.loaded,
          // Not the server's words ('Password changed' here): the screen
          // waits for this text
          message: 'Password reset successfully',
        ),
      ],
      verify: (_) {
        final saved =
            verify(() => saveCredentials(captureAny())).captured.single
                as SaveCredentialsParameters;
        expect(saved.email, 'karim@example.dz');
      },
    );
  });
}
