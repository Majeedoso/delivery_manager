import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/verify_email_otp_screen.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fake_backend.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';
import '../../../../helpers/platform.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// The 6-digit code sent to the manager's email, asked for by the account
/// status page while the email is not verified. A right code marks the
/// stored account verified, then the account's status decides the next
/// page; a code copied from the email is picked up by itself.
///
/// Pinput's cursor blinks forever once it has focus, so these tests pump by
/// hand ([answer]) while the code field is on screen.
void main() {
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late FakeBackend backend;
  late AuthLocalDataSource storedUser;
  late RouteLog routes;
  late StreamController<AuthState> session;

  const email = 'karim@example.dz';
  const verifyPath = '/auth/email/verify-email-otp';
  const wrongCode = 'Invalid or expired OTP. Please request a new one.';

  setUpAll(registerFallbacks);

  setUp(() async {
    auth = MockAuthBloc();
    countdown = MockCountdownBloc();
    backend = FakeBackend();
    routes = RouteLog();
    session = StreamController<AuthState>.broadcast();
    addTearDown(session.close);
    whenListen(auth, session.stream, initialState: const AuthState());
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(),
    );
    registerService<Dio>(testDio(backend));

    // What signing in stored: the manager, not verified yet (a token
    // given with the user is not kept: the preferences are plain)
    SharedPreferences.setMockInitialValues({});
    storedUser = AuthLocalDataSource(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    registerService<BaseAuthLocalDataSource>(storedUser);
    await storedUser.saveUser(
      UserModel.fromJson({
        ...userJson(emailVerifiedAt: null, status: 'pending_approval'),
        'token': 'tok',
      }),
    );
  });

  /// What the session check answers once the code is accepted.
  void sessionAnswers(AuthState state) => when(
    () => auth.add(CheckAuthStatusEvent()),
  ).thenAnswer((_) => session.add(state));

  AuthState signedIn({required String status}) => AuthState(
    requestState: RequestState.loaded,
    isAuthenticated: true,
    user: UserModel.fromJson(userJson(status: status)),
  );

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) => pumpPage(
    tester,
    const VerifyEmailOtpScreen(email: email),
    locale: locale,
    routes: routes,
    blocs: [
      BlocProvider<AuthBloc>.value(value: auth),
      BlocProvider<CountdownBloc>.value(value: countdown),
    ],
  );

  /// Lets the request and what follows it run.
  Future<void> answer(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> typeCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(Pinput), code);
    await answer(tester);
  }

  void acceptCode() => backend.reply(
    'POST',
    verifyPath,
    body: ok({
      'email': email,
      'email_verified_at': '2026-09-30T11:00:00.000000Z',
      'verified': true,
    }, message: 'Email verified successfully'),
  );

  void refuseCode() =>
      backend.reply('POST', verifyPath, status: 400, body: failure(wrongCode));

  testWidgets('says where the code went', (tester) async {
    await pump(tester);

    expect(find.text('OTP sent to $email'), findsOneWidget);
  });

  group('the resend countdown', () {
    testWidgets('starts on arrival: sign-up just sent a code', (tester) async {
      await pump(tester);

      verify(() => countdown.add(const StartCountdownEvent(120))).called(1);
    });

    testWidgets('lasts as long as the manager set on the server', (
      tester,
    ) async {
      publicSettings.values['otp_resend_wait_seconds'] = 45;

      await pump(tester);

      verify(() => countdown.add(const StartCountdownEvent(45))).called(1);
    });

    testWidgets('one already running is left alone', (tester) async {
      whenListen(
        countdown,
        const Stream<CountdownState>.empty(),
        initialState: const CountdownState(
          countdownSeconds: 30,
          isActive: true,
        ),
      );

      await pump(tester);

      verifyNever(() => countdown.add(any()));
      final resend = find.widgetWithText(TextButton, 'Resend OTP (30s)');
      expect(tester.widget<TextButton>(resend).onPressed, isNull);
    });
  });

  group('a right code', () {
    testWidgets('is sent as soon as it is complete', (tester) async {
      acceptCode();
      await pump(tester);

      await typeCode(tester, '123456');

      expect(backend.last('POST', verifyPath).json, {
        'email': email,
        'otp': '123456',
      });
    });

    testWidgets('keeps the stored manager a manager, now verified', (
      tester,
    ) async {
      acceptCode();
      await pump(tester);

      await typeCode(tester, '123456');

      final user = (await storedUser.getCurrentUser())!;
      expect(
        user.role,
        UserRole.manager,
        // M3: the role was saved as the text "UserRole.manager", which reads
        // back as an operator, and the status was lost
        reason: 'it was saved as "UserRole.manager", read back as operator',
      );
      expect(user.emailVerifiedAt, DateTime.utc(2026, 9, 30, 11));
      expect(user.status, 'pending_approval', reason: 'nothing else is lost');
      expect(user.name, 'Karim Haddad');
      expect(user.token, isNull, reason: 'kept in the encrypted storage only');
    });

    testWidgets('with nothing stored, the account saved is a manager\'s', (
      tester,
    ) async {
      await storedUser.clearUser();
      acceptCode();
      await pump(tester);

      await typeCode(tester, '123456');

      final user = (await storedUser.getCurrentUser())!;
      expect(user.role, UserRole.manager, reason: 'this is the manager app');
      expect(user.email, email);
      expect(user.emailVerifiedAt, DateTime.utc(2026, 9, 30, 11));
    });

    testWidgets('an account not approved yet then waits for approval', (
      tester,
    ) async {
      acceptCode();
      sessionAnswers(signedIn(status: 'pending_approval'));
      await pump(tester);

      await typeCode(tester, '123456');
      await tester.pumpAndSettle();

      verify(() => auth.add(CheckAuthStatusEvent())).called(1);
      verify(() => countdown.add(const StopCountdownEvent())).called(1);
      expect(routes.last.name, AppRoutes.accountStatus);
      expect(find.byType(VerifyEmailOtpScreen), findsNothing);
    });

    testWidgets('a manager already approved goes into the app', (tester) async {
      acceptCode();
      sessionAnswers(signedIn(status: 'active'));
      await pump(tester);

      await typeCode(tester, '123456');
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.main);
    });

    testWidgets('a session the server no longer knows goes back to login', (
      tester,
    ) async {
      acceptCode();
      sessionAnswers(const AuthState(requestState: RequestState.loaded));
      await pump(tester);

      await typeCode(tester, '123456');
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.login);
    });

    testWidgets('it stays put until the session check has answered', (
      tester,
    ) async {
      acceptCode();
      await pump(tester);

      await typeCode(tester, '123456');

      expect(find.byType(VerifyEmailOtpScreen), findsOneWidget);
      expect(routes.names, [Navigator.defaultRouteName]);
    });
  });

  group('a wrong code', () {
    testWidgets('shows why and keeps the screen', (tester) async {
      refuseCode();
      await pump(tester);

      await typeCode(tester, '123456');

      expect(find.textContaining('Invalid or expired OTP'), findsOneWidget);
      expect(find.byType(VerifyEmailOtpScreen), findsOneWidget);
      expect((await storedUser.getCurrentUser())!.emailVerifiedAt, isNull);
    });

    testWidgets('five of them lead back to login', (tester) async {
      refuseCode();
      await pump(tester);

      for (final code in ['111111', '222222', '333333', '444444', '555555']) {
        await typeCode(tester, code);
      }
      await tester.pumpAndSettle();

      expect(backend.count('POST', verifyPath), 5);
      expect(routes.last.name, AppRoutes.login);
    });

    testWidgets('no connection does not count as a wrong code', (tester) async {
      backend.fail('POST', verifyPath, DioExceptionType.connectionError);
      await pump(tester);

      for (final code in ['111111', '222222', '333333', '444444', '555555']) {
        await typeCode(tester, code);
      }

      expect(find.byType(VerifyEmailOtpScreen), findsOneWidget);
      expect(routes.names, isNot(contains(AppRoutes.login)));
    });
  });

  group('a code copied from the email', () {
    testWidgets('is filled in and sent once', (tester) async {
      refuseCode(); // a fast answer: the second send came after it
      await pump(tester);

      clipboard.text = 'Your verification code is 654321';
      await tester.pump(const Duration(seconds: 1));
      await answer(tester);
      await tester.pump(const Duration(seconds: 2));
      await answer(tester);

      expect(backend.last('POST', verifyPath).json['otp'], '654321');
      expect(backend.count('POST', verifyPath), 1);
    });

    testWidgets('an old code already copied is not used', (tester) async {
      clipboard.text = '111111';
      await pump(tester);

      await tester.pump(const Duration(seconds: 3));

      expect(backend.count('POST', verifyPath), 0);
    });
  });

  testWidgets('resend asks for a new code and restarts the countdown', (
    tester,
  ) async {
    backend.reply(
      'POST',
      '/auth/email/resend',
      body: ok({'resend_countdown': 90}),
    );
    await pump(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Resend OTP'));
    await answer(tester);

    expect(backend.count('POST', '/auth/email/resend'), 1);
    verify(() => countdown.add(const StartCountdownEvent(90))).called(1);
  });

  testWidgets('back goes to signing in (there is no sign-up)', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // It went to the sign-up choice, which this app no longer has (M1)
    expect(routes.last.name, AppRoutes.login);
    expect(find.text(routeText(AppRoutes.login)), findsOneWidget);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
