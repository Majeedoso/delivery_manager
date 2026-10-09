import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/reset_password_unauthenticated_screen.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/platform.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// The code screen of "forgot password": the 6-digit code from the email is
/// checked first, then the new password is set and login opens. A code
/// copied from the email is picked up by itself. Too many wrong codes send
/// the manager back for a new one.
///
/// Pinput's cursor blinks forever once it has focus, so these tests pump
/// by hand where the code field is focused.
void main() {
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late StreamController<AuthState> states;
  late RouteLog routes;

  const email = 'karim@example.dz';
  const codeAccepted = AuthState(
    requestState: RequestState.loaded,
    message: 'OTP verified successfully. You can now reset your password.',
  );
  const wrongCode = AuthState(
    requestState: RequestState.error,
    message: 'Invalid or expired OTP. Please request a new one.',
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

  List<BlocProvider> blocs() => [
    BlocProvider<AuthBloc>.value(value: auth),
    BlocProvider<CountdownBloc>.value(value: countdown),
  ];

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) => pumpPage(
    tester,
    const ResetPasswordUnauthenticatedScreen(email: email, otp: ''),
    locale: locale,
    routes: routes,
    blocs: blocs(),
  );

  Future<void> emit(WidgetTester tester, AuthState state) async {
    states.add(state);
    await tester.pump();
    await tester.pump(); // the mock bloc's stream adds a hop
  }

  Future<void> typeCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(Pinput), code);
    await tester.pump();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder resetButton() => find.widgetWithText(ElevatedButton, 'Reset Password');

  /// The screen once the code was accepted: the new-password form.
  Future<void> pumpAccepted(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await pump(tester, locale: locale);
    await typeCode(tester, '123456');
    await emit(tester, codeAccepted);
    await tester.pumpAndSettle(); // the code field is gone
  }

  group('the code', () {
    testWidgets('comes first, without the password fields', (tester) async {
      await pump(tester);

      expect(find.text('Enter OTP Code'), findsOneWidget);
      expect(find.byType(Pinput), findsOneWidget);
      expect(field('New Password'), findsNothing);
    });

    testWidgets('is checked as soon as it is complete', (tester) async {
      await pump(tester);

      await typeCode(tester, '123456');

      verify(
        () => auth.add(
          const VerifyPasswordResetOtpEvent(email: email, otp: '123456'),
        ),
      ).called(1);
    });

    testWidgets('an incomplete code is not sent', (tester) async {
      await pump(tester);

      await typeCode(tester, '12345');

      verifyNever(() => auth.add(any()));
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Verify OTP'),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('a wrong code shows why', (tester) async {
      await pump(tester);
      await typeCode(tester, '123456');

      await emit(tester, wrongCode);

      expect(find.text(wrongCode.message), findsOneWidget);
      expect(find.byType(Pinput), findsOneWidget, reason: 'try again');
    });

    testWidgets('five wrong codes send the manager back for a new one', (
      tester,
    ) async {
      await pumpPage(
        tester,
        const Text('home'),
        routes: routes,
        blocs: blocs(),
      );
      navigatorKey.currentState!.pushNamed(AppRoutes.login);
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const ResetPasswordUnauthenticatedScreen(email: email, otp: ''),
        ),
      );
      await tester.pumpAndSettle();

      for (var attempt = 1; attempt <= 5; attempt++) {
        await emit(tester, const AuthState(requestState: RequestState.loading));
        await emit(tester, wrongCode);
      }
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.forgotPassword);
      expect(find.byType(ResetPasswordUnauthenticatedScreen), findsNothing);

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(
        find.text(routeText(AppRoutes.login)),
        findsOneWidget,
        reason: 'back still leads to login (it used to close the app)',
      );
    });
  });

  group('a code copied from the email', () {
    testWidgets('is filled in and checked once', (tester) async {
      await pump(tester);

      clipboard.text = 'Your password reset code is 654321';
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('6'), findsOneWidget, reason: 'the first digit');
      verify(
        () => auth.add(
          const VerifyPasswordResetOtpEvent(email: email, otp: '654321'),
        ),
      ).called(1);
    });

    testWidgets('an old code already copied is not used', (tester) async {
      clipboard.text = '111111';
      await pump(tester);

      await tester.pump(const Duration(seconds: 3));

      verifyNever(() => auth.add(any()));
    });

    testWidgets('closing the screen stops looking', (tester) async {
      await pump(tester);

      await tester.pumpWidget(const SizedBox());

      // No expect: flutter_test fails any test that ends with a timer still
      // running, and the check used to run on after the screen was gone.
    });
  });

  group('resending', () {
    testWidgets('is offered once the countdown is over', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Resend OTP'));

      verify(
        () => auth.add(const ResendPasswordResetOtpEvent(email: email)),
      ).called(1);
    });

    testWidgets('waits while the countdown runs', (tester) async {
      whenListen(
        countdown,
        const Stream<CountdownState>.empty(),
        initialState: const CountdownState(
          countdownSeconds: 30,
          isActive: true,
        ),
      );
      await pump(tester);

      await tester.tap(find.text('You can resend OTP in 30s'));

      verifyNever(() => auth.add(any()));
    });

    testWidgets('a new code restarts the countdown', (tester) async {
      await pump(tester);

      await emit(
        tester,
        const AuthState(
          requestState: RequestState.loaded,
          message:
              'Password reset OTP sent successfully. Please check your email.',
          resendCountdown: 120,
        ),
      );

      verify(() => countdown.add(const StartCountdownEvent(120))).called(1);
    });
  });

  group('the new password', () {
    testWidgets('opens once the code is accepted', (tester) async {
      await pumpAccepted(tester);

      expect(find.text('Set New Password'), findsOneWidget);
      expect(field('New Password'), findsOneWidget);
      expect(field('Confirm Password'), findsOneWidget);
      expect(find.text('Resend OTP'), findsNothing);
    });

    testWidgets('follows the sign-up rule', (tester) async {
      await pumpAccepted(tester);

      await tester.enterText(field('New Password'), 'password1');
      await tester.enterText(field('Confirm Password'), 'password1');
      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Password must contain uppercase, lowercase, number, and symbol',
        ),
        findsOneWidget,
      );
      verifyNever(() => auth.add(any(that: isA<ResetPasswordEvent>())));
    });

    testWidgets('empty or different fields are refused', (tester) async {
      await pumpAccepted(tester);

      await tester.tap(resetButton());
      await tester.pumpAndSettle();
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);

      await tester.enterText(field('New Password'), 'Secret#2026');
      await tester.enterText(field('Confirm Password'), 'Secret#2025');
      await tester.tap(resetButton());
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('is sent with the accepted code', (tester) async {
      await pumpAccepted(tester);

      await tester.enterText(field('New Password'), 'Secret#2026');
      await tester.enterText(field('Confirm Password'), 'Secret#2026');
      await tester.tap(resetButton());
      await tester.pumpAndSettle();

      verify(
        () => auth.add(
          const ResetPasswordEvent(
            email: email,
            otp: '123456',
            password: 'Secret#2026',
            passwordConfirmation: 'Secret#2026',
          ),
        ),
      ).called(1);
    });

    testWidgets('once changed, login opens with nothing behind it', (
      tester,
    ) async {
      await pumpAccepted(tester);

      states.add(
        const AuthState(
          requestState: RequestState.loaded,
          message:
              'Password reset successfully. You can now login with your new password.',
        ),
      );
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.login);
      expect(find.byType(ResetPasswordUnauthenticatedScreen), findsNothing);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);
      expect(tester.takeException(), isNull, reason: 'the code');

      await pumpAccepted(tester, locale: locale);
      await tester.tap(
        resetButton().evaluate().isEmpty
            ? find.byType(ElevatedButton).first
            : resetButton(),
      );
      await tester.pumpAndSettle(); // with the error messages showing
      expect(tester.takeException(), isNull, reason: 'the new password');
    });
  }
}
