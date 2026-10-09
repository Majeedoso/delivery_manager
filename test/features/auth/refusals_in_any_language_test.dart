import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/services/device_info_service.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/google_auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/models/auth_response_model.dart';
import 'package:delivery_manager/features/auth/data/repository/auth_repository.dart';
import 'package:delivery_manager/features/auth/domain/entities/auth_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/clear_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
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
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/features/profile/data/models/confirm_email_change_response_model.dart';
import 'package:delivery_manager/features/profile/domain/entities/confirm_email_change_response.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_email_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/confirm_email_change_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/send_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/verify_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

/// The server answers in the app's language (decision 15 of the restaurant
/// report). The app decides on what the server names (its `error_code`) and on
/// its own words, never on the words of the server's messages: these tests
/// give it French and Arabic answers.
void main() {
  const arabicRefusal =
      'هذا الحساب حساب سائق. استخدم تطبيق السائق لتسجيل الدخول.';
  const frenchRefusal = 'Identifiants invalides';

  group('the server\'s code travels with its message', () {
    test('a refusal the server names keeps its code', () async {
      final source = _sourceAnswering(403, {
        'success': false,
        'message': arabicRefusal,
        'error_code': 'ROLE_MISMATCH',
      });

      await expectLater(
        source.login(email: 'amina@example.dz', password: 'Secret#2026'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', arabicRefusal)
              .having((e) => e.errorCode, 'errorCode', 'ROLE_MISMATCH'),
        ),
      );
    });

    test('a refusal without a code has none', () async {
      final source = _sourceAnswering(401, {'message': 'Invalid credentials'});

      await expectLater(
        source.login(email: 'amina@example.dz', password: 'wrong'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.errorCode,
            'errorCode',
            isNull,
          ),
        ),
      );
    });

    test('the repository hands the code over with the message', () async {
      final repository = AuthRepository(
        baseAuthRemoteDataSource: _RefusingRemote(),
        baseAuthLocalDataSource: _UnusedLocal(),
        baseGoogleAuthRemoteDataSource: _UnusedGoogle(),
        baseTokenRepository: _UnusedTokens(),
      );

      expect(
        await repository.login(email: 'amina@example.dz', password: 'wrong'),
        const Left<Failure, AuthResponse>(
          ServerFailure(frenchRefusal, errorCode: 'INVALID_CREDENTIALS'),
        ),
      );
      expect(
        const ServerFailure(frenchRefusal, errorCode: 'INVALID_CREDENTIALS'),
        isNot(const ServerFailure(frenchRefusal)),
      );
    });

    test('the code belongs to one state: the next one has none', () {
      const refused = AuthState(
        requestState: RequestState.error,
        message: frenchRefusal,
        errorCode: 'INVALID_CREDENTIALS',
      );

      final next = refused.copyWith(requestState: RequestState.loading);

      expect(next.errorCode, isNull);
      expect(next.message, frenchRefusal);
    });
  });

  group('the sign-in bloc', () {
    AuthBloc build({
      Either<Failure, AuthResponse>? login,
      Either<Failure, User>? google,
      Either<Failure, String>? reset,
    }) => AuthBloc(
      loginUseCase: _Login(login),
      logoutUseCase: _Logout(),
      getCurrentUserUseCase: _GetCurrentUser(),
      googleSignInUseCase: _GoogleSignIn(google),
      googleSignOutUseCase: _GoogleSignOut(),
      saveTokenUseCase: _SaveToken(),
      checkAuthStatusUseCase: _CheckAuthStatus(),
      clearTokenUseCase: _ClearToken(),
      resendVerificationEmailUseCase: _ResendVerificationEmail(),
      resendPasswordResetOtpUseCase: _ResendPasswordResetOtp(),
      verifyPasswordResetOtpUseCase: _VerifyPasswordResetOtp(),
      resetPasswordUseCase: _ResetPassword(reset),
      sendPasswordResetOtpAuthenticatedUseCase:
          _SendPasswordResetOtpAuthenticated(),
      verifyPasswordResetOtpAuthenticatedUseCase:
          _VerifyPasswordResetOtpAuthenticated(),
      resetPasswordAuthenticatedUseCase: _ResetPasswordAuthenticated(reset),
      loadCredentialsUseCase: _LoadCredentials(),
      saveCredentialsUseCase: _SaveCredentials(),
      logger: LoggingService(),
    );

    blocTest<AuthBloc, AuthState>(
      'a sign-in refusal keeps the server\'s code',
      build: () => build(
        login: const Left(
          ServerFailure(frenchRefusal, errorCode: 'INVALID_CREDENTIALS'),
        ),
      ),
      act: (bloc) => bloc.add(
        const LoginEvent(email: 'amina@example.dz', password: 'wrong'),
      ),
      expect: () => const [
        AuthState(requestState: RequestState.loading),
        AuthState(
          requestState: RequestState.error,
          message: frenchRefusal,
          errorCode: 'INVALID_CREDENTIALS',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a Google refusal keeps the server\'s code',
      build: () => build(
        google: const Left(
          ServerFailure(arabicRefusal, errorCode: 'ROLE_MISMATCH'),
        ),
      ),
      act: (bloc) => bloc.add(GoogleSignInEvent()),
      expect: () => const [
        AuthState(requestState: RequestState.loading),
        AuthState(
          requestState: RequestState.error,
          message: arabicRefusal,
          errorCode: 'ROLE_MISMATCH',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a reset password is said in the bloc\'s own words, whatever the server wrote',
      build: () =>
          build(reset: const Right('Mot de passe réinitialisé avec succès.')),
      act: (bloc) => bloc.add(
        const ResetPasswordEvent(
          email: 'amina@example.dz',
          otp: '123456',
          password: 'New#2026a',
          passwordConfirmation: 'New#2026a',
        ),
      ),
      expect: () => const [
        AuthState(requestState: RequestState.loading),
        AuthState(
          requestState: RequestState.loaded,
          message: 'Password reset successfully',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'so is a reset from the profile',
      build: () =>
          build(reset: const Right('تمت إعادة تعيين كلمة المرور بنجاح')),
      act: (bloc) => bloc.add(
        const ResetPasswordAuthenticatedEvent(
          otp: '123456',
          newPassword: 'New#2026a',
          newPasswordConfirmation: 'New#2026a',
        ),
      ),
      expect: () => const [
        AuthState(requestState: RequestState.loading),
        AuthState(
          requestState: RequestState.loaded,
          message: 'Password reset successfully',
        ),
      ],
    );
  });

  blocTest<ProfileBloc, ProfileState>(
    'a changed e-mail is said in the bloc\'s own words, whatever the server wrote',
    build: () => ProfileBloc(
      getProfileUseCase: _GetProfile(),
      updateProfileUseCase: _UpdateProfile(),
      changePasswordUseCase: _ChangePassword(),
      changeEmailUseCase: _ChangeEmail(),
      confirmEmailChangeUseCase: _ConfirmEmailChange(),
      sendDeleteAccountOtpUseCase: _SendDeleteAccountOtp(),
      verifyDeleteAccountOtpUseCase: _VerifyDeleteAccountOtp(),
      loadCredentialsUseCase: _LoadCredentials(),
      saveCredentialsUseCase: _SaveCredentials(),
      logger: LoggingService(),
    ),
    act: (bloc) => bloc.add(
      const ConfirmEmailChangeEvent(
        newEmail: 'nouveau@example.dz',
        otp: '123456',
      ),
    ),
    expect: () => [
      isA<ProfileState>().having(
        (s) => s.requestState,
        'requestState',
        RequestState.loading,
      ),
      isA<ProfileState>()
          .having((s) => s.requestState, 'requestState', RequestState.loaded)
          .having((s) => s.message, 'message', 'Email changed successfully'),
    ],
  );

  group('the sign-in page', () {
    late StreamController<AuthState> states;

    setUp(() {
      states = StreamController<AuthState>.broadcast();
      sl.registerFactory<LoadCredentialsUseCase>(() => _LoadCredentials());
    });

    tearDown(() async {
      await states.close();
      await sl.reset();
    });

    /// The sign-in page on a 360 x 780 phone, in [locale].
    Future<void> showPage(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
    }) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final bloc = _MockAuthBloc();
      whenListen(bloc, states.stream, initialState: const AuthState());

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            theme: _phoneTheme(MaterialTheme.lightTheme()),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<AuthBloc>.value(
              value: bloc,
              child: const LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    Future<void> refuse(
      WidgetTester tester,
      String message, {
      String? code,
    }) async {
      await showPage(tester);

      states.add(
        AuthState(
          requestState: RequestState.error,
          message: message,
          errorCode: code,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets(
      'the footer says this year\'s copyright in the app\'s language',
      (tester) async {
        // Decision 20: the year was written in the text, and the operator's
        // page said "© 2024. All rights reserved." in English
        await showPage(tester, locale: const Locale('fr'));

        expect(
          find.text(
            '© ${DateTime.now().year} Appli Gestionnaire. Tous droits réservés.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('an account of another app says so, in the server\'s words', (
      tester,
    ) async {
      await refuse(tester, arabicRefusal, code: 'ROLE_MISMATCH');

      expect(find.text('Wrong App'), findsOneWidget);
      expect(find.text(arabicRefusal), findsOneWidget);
    });

    testWidgets('wrong credentials open the explaining dialog', (tester) async {
      await refuse(tester, frenchRefusal, code: 'INVALID_CREDENTIALS');

      expect(find.text('Login Failed'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('an unknown account points to sign-up', (tester) async {
      await refuse(
        tester,
        'Compte introuvable. Veuillez d\'abord vous inscrire.',
        code: 'ACCOUNT_NOT_FOUND',
      );

      expect(find.text('Account Not Found'), findsOneWidget);
    });

    testWidgets('the words alone decide nothing', (tester) async {
      // The English sentence the page used to look for, without a code
      await refuse(tester, 'Invalid credentials');

      expect(find.text('Login Failed'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}

/// [theme] as a phone draws it: its styles name no font family, which on a
/// phone means Roboto; the test engine would use its square font instead.
ThemeData _phoneTheme(ThemeData theme) {
  TextStyle? phone(TextStyle? style) =>
      style?.copyWith(fontFamily: style.fontFamily ?? 'Roboto');

  ButtonStyle? button(ButtonStyle? style) => style?.copyWith(
    textStyle: style.textStyle == null
        ? null
        : WidgetStateProperty.resolveWith(
            (states) => phone(style.textStyle!.resolve(states)),
          ),
  );

  final input = theme.inputDecorationTheme;
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Roboto'),
    textButtonTheme: TextButtonThemeData(
      style: button(theme.textButtonTheme.style),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: button(theme.elevatedButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: button(theme.outlinedButtonTheme.style),
    ),
    inputDecorationTheme: input.copyWith(
      labelStyle: phone(input.labelStyle),
      floatingLabelStyle: phone(input.floatingLabelStyle),
      hintStyle: phone(input.hintStyle),
      errorStyle: phone(input.errorStyle),
    ),
    snackBarTheme: theme.snackBarTheme.copyWith(
      contentTextStyle: phone(theme.snackBarTheme.contentTextStyle),
    ),
    dialogTheme: theme.dialogTheme.copyWith(
      titleTextStyle: phone(theme.dialogTheme.titleTextStyle),
      contentTextStyle: phone(theme.dialogTheme.contentTextStyle),
    ),
  );
}

/// The data source, on a Dio that answers [status] with [body].
AuthRemoteDataSource _sourceAnswering(int status, Map<String, dynamic> body) =>
    AuthRemoteDataSource(
      dio: Dio(BaseOptions(baseUrl: 'https://api.example.test/api'))
        ..httpClientAdapter = _Answer(status, body),
      deviceInfoService: _NoDeviceId(),
    );

class _Answer implements HttpClientAdapter {
  _Answer(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

class _NoDeviceId extends Fake implements DeviceInfoService {
  @override
  Future<String?> getDeviceId() async => null;
}

class _RefusingRemote extends Fake implements BaseAuthRemoteDataSource {
  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async => throw const ServerException(
    message: 'Identifiants invalides',
    errorCode: 'INVALID_CREDENTIALS',
  );
}

class _UnusedLocal extends Fake implements BaseAuthLocalDataSource {}

class _UnusedGoogle extends Fake implements BaseGoogleAuthRemoteDataSource {}

class _UnusedTokens extends Fake implements BaseTokenRepository {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _Login extends Fake implements LoginUseCase {
  _Login(this.answer);

  final Either<Failure, AuthResponse>? answer;

  @override
  Future<Either<Failure, AuthResponse>> call(
    LoginParameters parameters,
  ) async => answer!;
}

class _GoogleSignIn extends Fake implements GoogleSignInUseCase {
  _GoogleSignIn(this.answer);

  final Either<Failure, User>? answer;

  @override
  Future<Either<Failure, User>> call(NoParameters parameters) async => answer!;
}

class _ResetPassword extends Fake implements ResetPasswordUseCase {
  _ResetPassword(this.answer);

  final Either<Failure, String>? answer;

  @override
  Future<Either<Failure, String>> call(
    ResetPasswordParameters parameters,
  ) async => answer!;
}

class _ResetPasswordAuthenticated extends Fake
    implements ResetPasswordAuthenticatedUseCase {
  _ResetPasswordAuthenticated(this.answer);

  final Either<Failure, String>? answer;

  @override
  Future<Either<Failure, String>> call(
    ResetPasswordAuthenticatedParameters parameters,
  ) async => answer!;
}

/// No credentials remembered: nothing to update after a reset or a change.
class _LoadCredentials extends Fake implements LoadCredentialsUseCase {
  @override
  Future<Either<Failure, Map<String, String?>>> call(
    NoParameters parameters,
  ) async => const Right({'email': null, 'rememberMe': null});
}

class _ConfirmEmailChange extends Fake implements ConfirmEmailChangeUseCase {
  @override
  Future<Either<Failure, ConfirmEmailChangeResponse>> call(
    ConfirmEmailChangeParameters parameters,
  ) async => Right(
    ConfirmEmailChangeResponseModel.fromJson({
      // The server's sentence, in the app's language
      'message': 'تم تغيير البريد الإلكتروني بنجاح. تم التحقق من بريدك الجديد.',
      'data': {'user_id': 7, 'new_email': parameters.newEmail},
    }),
  );
}

class _Logout extends Fake implements LogoutUseCase {}

class _GetCurrentUser extends Fake implements GetCurrentUserUseCase {}

class _GoogleSignOut extends Fake implements GoogleSignOutUseCase {}

class _SaveToken extends Fake implements SaveTokenUseCase {}

class _CheckAuthStatus extends Fake implements CheckAuthStatusUseCase {}

class _ClearToken extends Fake implements ClearTokenUseCase {}

class _ResendVerificationEmail extends Fake
    implements ResendVerificationEmailUseCase {}

class _ResendPasswordResetOtp extends Fake
    implements ResendPasswordResetOtpUseCase {}

class _VerifyPasswordResetOtp extends Fake
    implements VerifyPasswordResetOtpUseCase {}

class _SendPasswordResetOtpAuthenticated extends Fake
    implements SendPasswordResetOtpAuthenticatedUseCase {}

class _VerifyPasswordResetOtpAuthenticated extends Fake
    implements VerifyPasswordResetOtpAuthenticatedUseCase {}

class _SaveCredentials extends Fake implements SaveCredentialsUseCase {}

class _GetProfile extends Fake implements GetProfileUseCase {}

class _UpdateProfile extends Fake implements UpdateProfileUseCase {}

class _ChangePassword extends Fake implements ChangePasswordUseCase {}

class _ChangeEmail extends Fake implements ChangeEmailUseCase {}

class _SendDeleteAccountOtp extends Fake
    implements SendDeleteAccountOtpUseCase {}

class _VerifyDeleteAccountOtp extends Fake
    implements VerifyDeleteAccountOtpUseCase {}
