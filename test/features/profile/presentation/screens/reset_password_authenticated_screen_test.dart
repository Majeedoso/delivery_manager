import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/features/profile/presentation/screens/reset_password_authenticated_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/platform.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// "Forgot password" while signed in: a code to the manager's email, then
/// a new password; done, back to the profile.
///
/// Pinput's cursor blinks forever once it has focus, so these tests pump by
/// hand ([settle]) after typing.
void main() {
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late StreamController<AuthState> states;
  late RouteLog routes;
  final en = lookupAppLocalizations(const Locale('en'));

  const signedIn = AuthState(
    requestState: RequestState.loaded,
    isAuthenticated: true,
    user: User(
      id: 7,
      name: 'Karim',
      email: 'karim@example.dz',
      phone: '0550123456',
      role: UserRole.manager,
      hasPassword: true,
    ),
  );

  setUpAll(registerFallbacks);

  setUp(() {
    auth = MockAuthBloc();
    countdown = MockCountdownBloc();
    states = StreamController<AuthState>.broadcast();
    routes = RouteLog();
    whenListen(auth, states.stream, initialState: signedIn);
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(),
    );
  });

  tearDown(() => states.close());

  /// The profile page, with this page opened above it.
  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await pumpOpener<void>(
      tester,
      (context) async {
        final navigator = Navigator.of(context);
        unawaited(
          navigator.push(
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: AppRoutes.profile),
              builder: (_) => const Scaffold(body: Text('the profile')),
            ),
          ),
        );
        await navigator.push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(
              name: AppRoutes.resetPasswordAuthenticated,
            ),
            builder: (_) => const ResetPasswordAuthenticatedScreen(),
          ),
        );
      },
      locale: locale,
      routes: routes,
      blocs: [
        BlocProvider<AuthBloc>.value(value: auth),
        BlocProvider<CountdownBloc>.value(value: countdown),
      ],
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  List<String> codesSent() =>
      verify(
            () => auth.add(
              captureAny(that: isA<VerifyPasswordResetOtpAuthenticatedEvent>()),
            ),
          ).captured
          .map((e) => (e as VerifyPasswordResetOtpAuthenticatedEvent).otp)
          .toList();

  Future<void> codeAccepted(WidgetTester tester) async {
    await tester.enterText(find.byType(Pinput), '123456');
    await settle(tester);
    states.add(
      signedIn.copyWith(
        message: 'OTP verified successfully. You can now reset your password.',
      ),
    );
    await settle(tester);
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('sends a code to the manager\'s email on arrival', (
    tester,
  ) async {
    await open(tester);

    verify(
      () => auth.add(const SendPasswordResetOtpAuthenticatedEvent()),
    ).called(1);
    expect(find.text('${en.otpSentTo} karim@example.dz'), findsOneWidget);
  });

  testWidgets('a code still valid is not sent again', (tester) async {
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(countdownSeconds: 30, isActive: true),
    );

    await open(tester);

    verifyNever(() => auth.add(const SendPasswordResetOtpAuthenticatedEvent()));
  });

  testWidgets('a complete code is checked', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(Pinput), '123456');
    await settle(tester);

    expect(codesSent(), ['123456']);
  });

  testWidgets('a code copied from the email is filled in and checked once', (
    tester,
  ) async {
    await open(tester);

    clipboard.text = 'Code: 987654';
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);

    expect(codesSent(), [
      '987654',
    ], reason: 'a delayed second check went out after the first');
  });

  testWidgets('a wrong code says why', (tester) async {
    await open(tester);

    states.add(
      signedIn.copyWith(
        requestState: RequestState.error,
        message: 'Invalid or expired OTP',
      ),
    );
    await settle(tester);

    expect(find.text('Invalid or expired OTP'), findsOneWidget);
    expect(field(en.newPassword), findsNothing);
  });

  group('the new password', () {
    testWidgets('asked for once the code is right', (tester) async {
      await open(tester);

      await codeAccepted(tester);

      expect(field(en.newPassword), findsOneWidget);
      expect(find.byType(Pinput), findsNothing);
    });

    testWidgets('a strong one, typed twice, is sent with the code', (
      tester,
    ) async {
      await open(tester);
      await codeAccepted(tester);

      await tester.enterText(field(en.newPassword), 'New-pass1!');
      await tester.enterText(field(en.confirmNewPassword), 'New-pass1!');
      await tester.tap(find.widgetWithText(ElevatedButton, en.resetPassword));
      await settle(tester);

      verify(
        () => auth.add(
          const ResetPasswordAuthenticatedEvent(
            otp: '123456',
            newPassword: 'New-pass1!',
            newPasswordConfirmation: 'New-pass1!',
          ),
        ),
      ).called(1);
    });

    testWidgets('a weak or mistyped one is refused', (tester) async {
      await open(tester);
      await codeAccepted(tester);

      await tester.enterText(field(en.newPassword), 'short');
      await tester.enterText(field(en.confirmNewPassword), 'other');
      await tester.tap(find.widgetWithText(ElevatedButton, en.resetPassword));
      await settle(tester);

      expect(find.text(en.passwordMinLength8), findsOneWidget);
      expect(find.text(en.passwordsDoNotMatch), findsOneWidget);
      verifyNever(
        () => auth.add(any(that: isA<ResetPasswordAuthenticatedEvent>())),
      );
    });

    testWidgets('set: back to the profile it came from', (tester) async {
      await open(tester);
      await codeAccepted(tester);
      final pushed = routes.pushed.length;

      states.add(signedIn.copyWith(message: 'Password reset successfully'));
      await tester.pumpAndSettle();

      verify(() => countdown.add(const StopCountdownEvent())).called(1);
      expect(find.text('the profile'), findsOneWidget);
      expect(find.byType(ResetPasswordAuthenticatedScreen), findsNothing);
      expect(
        routes.pushed,
        hasLength(pushed),
        reason: 'a second profile page was pushed above this one',
      );
    });
  });

  testWidgets('resend, once the timer is over', (tester) async {
    await open(tester);
    clearInteractions(auth);

    await scrollTo(tester, find.text(en.resendOtp));
    await tester.tap(find.text(en.resendOtp));
    await tester.pump();

    verify(
      () => auth.add(const SendPasswordResetOtpAuthenticatedEvent()),
    ).called(1);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await open(tester, locale: locale);
      expect(tester.takeException(), isNull);

      await codeAccepted(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
