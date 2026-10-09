import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/account_status_screen.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// Where a signed-in manager lands when the app can't open yet: an email
/// still to verify, or a suspended or rejected account. Each case says what
/// happened and offers what can be done about it.
void main() {
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late StreamController<AuthState> states;
  late RouteLog routes;

  UserModel manager({String status = 'active', bool verified = false}) =>
      UserModel.fromJson(
        userJson(
          status: status,
          emailVerifiedAt: verified ? '2026-09-30T11:00:00.000000Z' : null,
        ),
      );

  AuthState signedIn(UserModel user) => AuthState(
    requestState: RequestState.loaded,
    isAuthenticated: true,
    user: user,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    auth = MockAuthBloc();
    countdown = MockCountdownBloc();
    states = StreamController<AuthState>.broadcast();
    routes = RouteLog();
    whenListen(auth, states.stream, initialState: signedIn(manager()));
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(),
    );
  });

  tearDown(() => states.close());

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool settle = true,
  }) => pumpPage(
    tester,
    const AccountStatusScreen(),
    locale: locale,
    settle: settle,
    routes: routes,
    blocs: [
      BlocProvider<AuthBloc>.value(value: auth),
      BlocProvider<CountdownBloc>.value(value: countdown),
    ],
  );

  Future<void> emit(WidgetTester tester, AuthState state) async {
    states.add(state);
    await tester.pump();
    await tester.pump(); // the mock bloc's stream adds a hop
  }

  Finder resend() => find.text('Resend Verification');

  group('an email to verify', () {
    testWidgets('says so and offers the code', (tester) async {
      await pump(tester);

      expect(find.text('Email Not Verified'), findsOneWidget);
      expect(resend(), findsOneWidget);
      expect(find.text('Check Status'), findsOneWidget);
    });

    testWidgets('a new code opens the code screen, with its countdown', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(resend());
      verify(() => auth.add(ResendVerificationEmailEvent())).called(1);
      await emit(
        tester,
        signedIn(
          manager(),
        ).copyWith(message: 'verificationEmailSent', resendCountdown: 120),
      );
      await tester.pumpAndSettle();

      verify(() => countdown.add(const StartCountdownEvent(120))).called(1);
      expect(routes.last.name, AppRoutes.verifyEmailOtp);
      expect(routes.lastArguments, {'email': 'karim@example.dz'});
    });

    testWidgets('while the last code is fresh, no new one is sent', (
      tester,
    ) async {
      whenListen(
        countdown,
        const Stream<CountdownState>.empty(),
        initialState: const CountdownState(
          countdownSeconds: 45,
          isActive: true,
        ),
      );
      await pump(tester);

      await tester.tap(find.text('Resend Verification (45s)'));
      await tester.pumpAndSettle();

      verifyNever(() => auth.add(any()));
      expect(routes.last.name, AppRoutes.verifyEmailOtp);
    });

    testWidgets('check status asks the server again', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Check Status'));

      verify(() => auth.add(CheckAuthStatusEvent())).called(1);
    });

    testWidgets('once verified, the app starts over from the splash', (
      tester,
    ) async {
      await pump(tester);

      states.add(signedIn(manager(verified: true)));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.splash);
      expect(find.byType(AccountStatusScreen), findsNothing);
    });
  });

  group('a closed account', () {
    testWidgets('suspended: says so, with no code to send', (tester) async {
      whenListen(
        auth,
        states.stream,
        initialState: signedIn(manager(status: 'suspended', verified: true)),
      );
      await pump(tester);

      expect(find.text('Account Suspended'), findsOneWidget);
      expect(
        find.text(
          'Your account has been suspended. Please contact support for assistance.',
        ),
        findsOneWidget,
      );
      expect(resend(), findsNothing);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('rejected: shows the reason', (tester) async {
      whenListen(
        auth,
        states.stream,
        initialState: signedIn(
          UserModel.fromJson({
            ...userJson(status: 'rejected'),
            'rejection_reason': 'Duplicate account',
          }),
        ),
      );
      await pump(tester);

      expect(find.text('Account Rejected'), findsOneWidget);
      expect(find.text('Duplicate account'), findsOneWidget);
    });
  });

  testWidgets('logout signs out and leaves for login', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    verify(() => auth.add(LogoutEvent())).called(1);
    expect(routes.last.name, AppRoutes.login);
    expect(find.byType(AccountStatusScreen), findsNothing);
  });

  testWidgets('a technical error is not shown as is', (tester) async {
    await pump(tester);

    await emit(
      tester,
      signedIn(manager()).copyWith(
        requestState: RequestState.error,
        message: 'SQLSTATE[HY000] [2002] Connection refused',
      ),
    );

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('SQLSTATE'), findsNothing);
  });

  testWidgets('with nobody loaded yet, it waits', (tester) async {
    whenListen(auth, states.stream, initialState: const AuthState());

    await pump(tester, settle: false);

    expect(find.byType(Lottie), findsOneWidget);
  });

  testWidgets('settings', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(routes.last.name, AppRoutes.settings);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);
      expect(tester.takeException(), isNull, reason: 'email to verify');

      whenListen(
        auth,
        states.stream,
        initialState: signedIn(manager(status: 'suspended', verified: true)),
      );
      await pump(tester, locale: locale);
      expect(tester.takeException(), isNull, reason: 'suspended');
    });
  }
}
