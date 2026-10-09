import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/models/auth_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_password_reset_otp_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/resend_verification_email_response_model.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/data/models/verify_email_otp_response_model.dart';
import 'package:delivery_manager/features/auth/data/repository/auth_repository.dart';
import 'package:delivery_manager/features/auth/data/repository/token_repository.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fake_backend.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';
import '../../../../helpers/pump.dart';

/// AuthRepository joins the account API, Google sign-in and the phone's
/// storage: a successful sign-in is remembered, a logout forgets locally at
/// once and revokes the token on the server in the background, and every
/// failure comes back as a Failure rather than an exception.
void main() {
  late MockAuthRemoteDataSource api;
  late MockGoogleAuthRemoteDataSource google;
  late AuthLocalDataSource local;
  late TokenRepository tokens;
  late AuthRepository repository;

  final signedIn = AuthResponseModel.fromJson(authJson(token: '1|abcdef'));
  const server = ServerException(message: 'Invalid credentials');
  const offline = NetworkException(message: 'Cannot connect to server');

  /// The token as an earlier version also kept it: in the plain preferences.
  Future<String?> plainCopy() async =>
      (await SharedPreferences.getInstance()).getString('auth_token');

  setUp(() async {
    api = MockAuthRemoteDataSource();
    google = MockGoogleAuthRemoteDataSource();
    local = AuthLocalDataSource(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    tokens = TokenRepository(
      localDataSource: TokenLocalDataSource(),
      remoteDataSource: MockTokenRemoteDataSource(),
    );
    repository = AuthRepository(
      baseAuthRemoteDataSource: api,
      baseAuthLocalDataSource: local,
      baseGoogleAuthRemoteDataSource: google,
      baseTokenRepository: tokens,
    );
    when(() => api.logout(token: any(named: 'token'))).thenAnswer((_) async {});
  });

  group('login', () {
    Future<Either<Failure, dynamic>> login() =>
        repository.login(email: 'karim@example.dz', password: 'Secret#2026');

    test('remembers the user and the token', () async {
      when(
        () => api.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => signedIn);

      expect(await login(), Right<Failure, dynamic>(signedIn));
      expect((await local.getCurrentUser())?.email, 'karim@example.dz');
      // In the encrypted storage, and no longer in the plain preferences
      expect(
        await tokens.getToken(),
        const Right<Failure, String?>('1|abcdef'),
      );
      expect(await plainCopy(), isNull);
    });

    test('a refusal or no connection comes back as a failure', () async {
      when(
        () => api.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(server);
      expect(
        await login(),
        const Left<Failure, dynamic>(ServerFailure('Invalid credentials')),
      );

      // The server's name for the refusal travels with its message
      when(
        () => api.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ServerException(
          message: 'Identifiants invalides',
          errorCode: 'INVALID_CREDENTIALS',
        ),
      );
      expect(
        await login(),
        const Left<Failure, dynamic>(
          ServerFailure(
            'Identifiants invalides',
            errorCode: 'INVALID_CREDENTIALS',
          ),
        ),
      );
      expect(
        const ServerFailure(
          'Identifiants invalides',
          errorCode: 'INVALID_CREDENTIALS',
        ),
        isNot(const ServerFailure('Identifiants invalides')),
      );

      when(
        () => api.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(offline);
      expect(
        await login(),
        const Left<Failure, dynamic>(
          NetworkFailure('Cannot connect to server'),
        ),
      );
      expect(await local.getCurrentUser(), isNull, reason: 'nothing saved');
    });

    test('anything unexpected is a failure too, never a throw', () async {
      when(
        () => api.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(StateError('bad JSON'));

      final result = await login();

      expect(result.isLeft(), isTrue, reason: 'the login spinner must stop');
    });
  });

  group('logout', () {
    setUp(() async {
      await local.saveUser(UserModel.fromJson(userJson()));
      await tokens.saveToken('1|secure');
    });

    test('forgets the user at once', () async {
      expect(await repository.logout(), const Right<Failure, void>(null));

      expect(await local.getCurrentUser(), isNull);
    });

    test('removes the plain copy an earlier version left', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', '1|prefs');

      await repository.logout();

      expect(await plainCopy(), isNull);
    });

    test(
      'revokes on the server the token the app sends with requests',
      () async {
        await repository.logout();
        await flushAsync();

        verify(() => api.logout(token: '1|secure')).called(1);
      },
    );

    test('a plain copy left by an earlier version is never sent', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', '1|prefs');
      await tokens.clearToken();

      await repository.logout();
      await flushAsync();

      verifyNever(() => api.logout(token: any(named: 'token')));
    });

    test(
      'a server that fails or is unreachable doesn\'t stop the logout',
      () async {
        when(() => api.logout(token: any(named: 'token'))).thenThrow(offline);

        expect(await repository.logout(), const Right<Failure, void>(null));
        await flushAsync();
        expect(await local.getCurrentUser(), isNull);
      },
    );

    test('with no token at all, the server isn\'t called', () async {
      await tokens.clearToken();

      await repository.logout();
      await flushAsync();

      verifyNever(() => api.logout(token: any(named: 'token')));
    });
  });

  group('the current user', () {
    late FakeBackend backend;

    setUp(() {
      backend = FakeBackend();
      registerService<Dio>(testDio(backend));
    });

    test('nobody signed in is null', () async {
      expect(
        await repository.getCurrentUser(),
        const Right<Failure, User?>(null),
      );
    });

    test('is refreshed from the server and saved', () async {
      await local.saveUser(UserModel.fromJson(userJson(status: 'active')));
      await tokens.saveToken('1|secure');
      backend.reply(
        'GET',
        '/auth/user',
        body: ok(userJson(status: 'suspended')),
      );

      final user = (await repository.getCurrentUser()).getOrElse(() => null);

      expect(user?.status, 'suspended');
      expect((await local.getCurrentUser())?.status, 'suspended');
      expect(
        backend.last('GET', '/auth/user').headers['Authorization'],
        'Bearer 1|secure',
      );
    });

    test('offline, the saved user is used', () async {
      await local.saveUser(UserModel.fromJson(userJson()));
      await tokens.saveToken('1|secure');
      backend.fail('GET', '/auth/user', DioExceptionType.connectionError);

      final user = (await repository.getCurrentUser()).getOrElse(() => null);

      expect(user?.email, 'karim@example.dz');
    });

    test('without a token the saved user is used as is', () async {
      await local.saveUser(UserModel.fromJson(userJson()));

      final user = (await repository.getCurrentUser()).getOrElse(() => null);

      expect(user?.email, 'karim@example.dz');
      expect(backend.requests, isEmpty);
    });
  });

  group('Google', () {
    final googleUser = UserModel.fromJson({...userJson(), 'token': '9|g'});

    test(
      'signing in remembers the user and keeps the token securely',
      () async {
        when(
          () => google.signInWithGoogle(),
        ).thenAnswer((_) async => googleUser);

        expect(
          await repository.googleSignIn(),
          Right<Failure, User>(googleUser),
        );
        expect((await local.getCurrentUser())?.role, UserRole.manager);
        expect(await tokens.getToken(), const Right<Failure, String?>('9|g'));
      },
    );

    test('failures are failures', () async {
      when(() => google.signInWithGoogle()).thenThrow(
        const ServerException(message: 'Google sign-in was cancelled'),
      );

      expect(
        await repository.googleSignIn(),
        const Left<Failure, User>(
          ServerFailure('Google sign-in was cancelled'),
        ),
      );
    });

    test('signing out forgets the local account', () async {
      when(() => google.signOutFromGoogle()).thenAnswer((_) async {});
      await local.saveUser(googleUser);

      expect(
        await repository.googleSignOut(),
        const Right<Failure, void>(null),
      );
      expect(await local.getCurrentUser(), isNull);
    });
  });

  group('the one-time codes pass the API\'s answer through', () {
    const emailSent = ResendVerificationEmailResponseModel(
      email: 'karim@example.dz',
      expiresIn: 600,
      resendCountdown: 60,
    );
    const resetSent = ResendPasswordResetOtpResponseModel(
      email: 'karim@example.dz',
      expiresIn: 600,
      resendCountdown: 60,
    );

    final calls =
        <
          String,
          (
            void Function(Object error),
            Future<Either<Failure, Object?>> Function(),
            Object?,
          )
        >{
          'resendVerificationEmail': (
            (error) => when(() => api.resendVerificationEmail()).thenAnswer(
              (_) async => error is Exception ? throw error : emailSent,
            ),
            () => repository.resendVerificationEmail(),
            emailSent,
          ),
          'resendPasswordResetOtp': (
            (error) => when(() => api.resendPasswordResetOtp(any())).thenAnswer(
              (_) async => error is Exception ? throw error : resetSent,
            ),
            () => repository.resendPasswordResetOtp('karim@example.dz'),
            resetSent,
          ),
          'sendPasswordResetOtpAuthenticated': (
            (error) =>
                when(() => api.sendPasswordResetOtpAuthenticated()).thenAnswer(
                  (_) async => error is Exception ? throw error : resetSent,
                ),
            () => repository.sendPasswordResetOtpAuthenticated(),
            resetSent,
          ),
          'resetPassword': (
            (error) =>
                when(
                  () => api.resetPassword(
                    email: any(named: 'email'),
                    otp: any(named: 'otp'),
                    password: any(named: 'password'),
                    passwordConfirmation: any(named: 'passwordConfirmation'),
                  ),
                ).thenAnswer(
                  (_) async => error is Exception ? throw error : 'Done',
                ),
            () => repository.resetPassword(
              email: 'karim@example.dz',
              otp: '1',
              password: 'p',
              passwordConfirmation: 'p',
            ),
            'Done',
          ),
          'resetPasswordAuthenticated': (
            (error) =>
                when(
                  () => api.resetPasswordAuthenticated(
                    otp: any(named: 'otp'),
                    newPassword: any(named: 'newPassword'),
                    newPasswordConfirmation: any(
                      named: 'newPasswordConfirmation',
                    ),
                  ),
                ).thenAnswer(
                  (_) async => error is Exception ? throw error : 'Done',
                ),
            () => repository.resetPasswordAuthenticated(
              otp: '1',
              newPassword: 'p',
              newPasswordConfirmation: 'p',
            ),
            'Done',
          ),
          'verifyPasswordResetOtp': (
            (error) =>
                when(
                  () => api.verifyPasswordResetOtp(
                    email: any(named: 'email'),
                    otp: any(named: 'otp'),
                  ),
                ).thenAnswer((_) async {
                  if (error is Exception) throw error;
                }),
            () => repository.verifyPasswordResetOtp(email: 'e', otp: '1'),
            null,
          ),
          'verifyPasswordResetOtpAuthenticated': (
            (error) =>
                when(
                  () => api.verifyPasswordResetOtpAuthenticated(
                    otp: any(named: 'otp'),
                  ),
                ).thenAnswer((_) async {
                  if (error is Exception) throw error;
                }),
            () => repository.verifyPasswordResetOtpAuthenticated(otp: '1'),
            null,
          ),
        };

    calls.forEach((name, call) {
      final (stub, run, value) = call;

      test('$name: the answer, or the failure it stands for', () async {
        stub('ok');
        expect(await run(), Right<Failure, Object?>(value));

        stub(server);
        expect(
          await run(),
          const Left<Failure, Object?>(ServerFailure('Invalid credentials')),
        );

        stub(offline);
        expect(
          await run(),
          const Left<Failure, Object?>(
            NetworkFailure('Cannot connect to server'),
          ),
        );

        stub(const FormatException('bad'));
        expect((await run()).isLeft(), isTrue);
      });
    });
  });

  test('a verified email keeps the token the app already had', () async {
    await local.saveUser(UserModel.fromJson(userJson()));
    await tokens.saveToken('1|kept');
    when(
      () => api.verifyEmailOtp(
        email: any(named: 'email'),
        otp: any(named: 'otp'),
      ),
    ).thenAnswer(
      (_) async => VerifyEmailOtpResponseModel(
        user: UserModel.fromJson(userJson()),
        message: 'Email verified',
      ),
    );

    final answer = await repository.verifyEmailOtp(
      email: 'karim@example.dz',
      otp: '123456',
    );

    expect(answer.getOrElse(() => throw 'failed').user.token, '1|kept');
    // In memory only: the saved user is in the plain preferences
    expect((await local.getCurrentUser())?.token, isNull);
  });
}
