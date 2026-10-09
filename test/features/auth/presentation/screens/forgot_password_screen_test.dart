import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// "Forgot password": the manager's email gets a reset code, then the code
/// screen opens. While the last code is still fresh (the resend countdown
/// runs), the button opens the code screen without sending another.
void main() {
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late StreamController<AuthState> states;
  late RouteLog routes;

  const codeSent = AuthState(
    requestState: RequestState.loaded,
    message: 'Password reset OTP sent successfully. Please check your email.',
    resendCountdown: 120,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    auth = MockAuthBloc();
    countdown = MockCountdownBloc();
    states = StreamController<AuthState>.broadcast();
    routes = RouteLog();
    whenListen(auth, states.stream, initialState: const AuthState());
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
  }) => pumpPage(
    tester,
    const ForgotPasswordScreen(),
    locale: locale,
    routes: routes,
    blocs: [
      BlocProvider<AuthBloc>.value(value: auth),
      BlocProvider<CountdownBloc>.value(value: countdown),
    ],
  );

  Finder emailField() => find.widgetWithText(TextFormField, 'Email Address');
  Finder button() => find.byType(ElevatedButton);

  Future<void> send(WidgetTester tester, String email) async {
    await tester.enterText(emailField(), email);
    await tester.tap(button());
    await tester.pumpAndSettle();
  }

  group('the email', () {
    testWidgets('empty is refused', (tester) async {
      await pump(tester);

      await send(tester, '');

      expect(find.text('Please enter your email'), findsOneWidget);
      verifyNever(() => auth.add(any()));
    });

    testWidgets('a malformed address is refused', (tester) async {
      await pump(tester);

      await send(tester, 'karim@example');

      expect(find.text('Please enter a valid email'), findsOneWidget);
      verifyNever(() => auth.add(any()));
    });

    testWidgets('a space around it is fine, and is not sent', (tester) async {
      await pump(tester);

      await send(tester, ' karim@example.dz ');

      verify(
        () => auth.add(
          const ResendPasswordResetOtpEvent(email: 'karim@example.dz'),
        ),
      ).called(1);
    });
  });

  group('once the code is sent', () {
    testWidgets('the countdown starts and the code screen opens', (
      tester,
    ) async {
      await pump(tester);
      await send(tester, 'karim@example.dz');

      states.add(codeSent);
      await tester.pumpAndSettle();

      verify(() => countdown.add(const StartCountdownEvent(120))).called(1);
      expect(routes.last.name, AppRoutes.resetPasswordUnauthenticated);
      expect(routes.lastArguments, {'email': 'karim@example.dz', 'otp': ''});
    });

    testWidgets('a countdown already running is left alone', (tester) async {
      await pump(tester);
      await send(tester, 'karim@example.dz');
      when(
        () => countdown.state,
      ).thenReturn(const CountdownState(countdownSeconds: 100, isActive: true));

      states.add(codeSent);
      await tester.pumpAndSettle();

      verifyNever(() => countdown.add(any()));
    });

    testWidgets('a refusal shows in a snackbar', (tester) async {
      await pump(tester);
      await send(tester, 'karim@example.dz');

      states.add(
        const AuthState(
          requestState: RequestState.error,
          message: 'Failed to send OTP. Please try again.',
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Failed to send OTP. Please try again.'),
        findsOneWidget,
      );
      expect(
        routes.names,
        isNot(contains(AppRoutes.resetPasswordUnauthenticated)),
      );
    });
  });

  group('while the last code is fresh', () {
    setUp(() {
      whenListen(
        countdown,
        const Stream<CountdownState>.empty(),
        initialState: const CountdownState(
          countdownSeconds: 90,
          isActive: true,
        ),
      );
    });

    testWidgets('the code screen opens without a new code', (tester) async {
      await pump(tester);
      expect(find.text('You can resend OTP in 90s'), findsOneWidget);

      await send(tester, 'karim@example.dz');

      verifyNever(() => auth.add(any()));
      expect(routes.last.name, AppRoutes.resetPasswordUnauthenticated);
      expect(routes.lastArguments['email'], 'karim@example.dz');
    });

    testWidgets('the email is still required', (tester) async {
      await pump(tester);

      await send(tester, '');

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(
        routes.names,
        isNot(contains(AppRoutes.resetPasswordUnauthenticated)),
        reason: 'the code screen would reset the password of nobody',
      );
    });
  });

  testWidgets('while sending, the button is off', (tester) async {
    await pump(tester);

    states.add(const AuthState(requestState: RequestState.loading));
    await tester.pump();
    await tester.pump(); // the mock bloc's stream adds a hop

    expect(tester.widget<ElevatedButton>(button()).onPressed, isNull);
  });

  testWidgets('under the code screen it stays quiet', (tester) async {
    await pump(tester);
    await tester.enterText(emailField(), 'karim@example.dz');
    navigatorKey.currentState!.pushNamed(
      AppRoutes.resetPasswordUnauthenticated,
    );
    await tester.pumpAndSettle();
    final opened = routes.pushed.length;

    states.add(codeSent); // "resend" on the code screen
    await tester.pumpAndSettle();
    states.add(
      const AuthState(
        requestState: RequestState.error,
        message: 'Invalid or expired OTP. Please request a new one.',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(routes.pushed, hasLength(opened), reason: 'no second code screen');
    expect(
      find.byType(SnackBar),
      findsNothing,
      reason: 'the code screen shows its own errors',
    );
    verifyNever(() => countdown.add(any()));
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);

      await tester.tap(button()); // with the error message showing
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
