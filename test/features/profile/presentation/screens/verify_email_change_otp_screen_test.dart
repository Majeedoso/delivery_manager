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
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/features/profile/presentation/screens/verify_email_change_otp_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/platform.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// The code sent to the new email address: a right code changes the email
/// and closes the page; the code can be sent again once the timer runs out.
///
/// Pinput's cursor blinks forever once it has focus, so these tests pump by
/// hand ([settle]) after typing.
void main() {
  late MockProfileBloc profile;
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late StreamController<ProfileState> states;
  late RouteLog routes;
  final en = lookupAppLocalizations(const Locale('en'));

  User user({String? googleId}) => User(
    id: 7,
    name: 'Karim',
    email: 'karim@example.dz',
    phone: '0550123456',
    role: UserRole.manager,
    googleId: googleId,
    hasPassword: googleId == null,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    profile = MockProfileBloc();
    auth = MockAuthBloc();
    countdown = MockCountdownBloc();
    states = StreamController<ProfileState>.broadcast();
    routes = RouteLog();
    whenListen(profile, states.stream, initialState: const ProfileState());
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(),
    );
    SharedPreferences.setMockInitialValues({
      'pending_email_change': 'new@example.dz',
    });
  });

  tearDown(() => states.close());

  Future<void> open(
    WidgetTester tester, {
    String? password = 'Old-pass1',
    String? googleId,
    Locale locale = const Locale('en'),
  }) async {
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: AuthState(
        requestState: RequestState.loaded,
        user: user(googleId: googleId),
      ),
    );
    await pumpOpener<void>(
      tester,
      (context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider<ProfileBloc>.value(
            value: profile,
            child: VerifyEmailChangeOtpScreen(
              newEmail: 'new@example.dz',
              currentPassword: password,
            ),
          ),
        ),
      ),
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

  List<ConfirmEmailChangeEvent> confirmations() => verify(
    () => profile.add(captureAny(that: isA<ConfirmEmailChangeEvent>())),
  ).captured.cast<ConfirmEmailChangeEvent>();

  testWidgets('the resend timer starts on arrival', (tester) async {
    await open(tester);

    verify(() => countdown.add(const StartCountdownEvent(120))).called(1);
  });

  testWidgets('a complete code is sent for the new address', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(Pinput), '123456');
    await settle(tester);

    expect(confirmations(), [
      const ConfirmEmailChangeEvent(newEmail: 'new@example.dz', otp: '123456'),
    ]);
  });

  testWidgets('a code copied from the email is filled in and sent once', (
    tester,
  ) async {
    await open(tester);

    clipboard.text = 'Your code: 654321';
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);

    expect(confirmations().map((e) => e.otp), [
      '654321',
    ], reason: 'a delayed second send went out after the first');
  });

  testWidgets('changed: the new email is signed in, the page closes', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await open(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.loaded,
        message: 'Email changed successfully',
      ),
    );
    await tester.pumpAndSettle();

    verify(() => countdown.add(const StopCountdownEvent())).called(1);
    verify(() => auth.add(any(that: isA<CheckAuthStatusEvent>()))).called(1);
    expect(find.byType(VerifyEmailChangeOtpScreen), findsNothing);
    expect(prefs.getString('pending_email_change'), isNull);
  });

  testWidgets('a wrong code says why and stays', (tester) async {
    await open(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.error,
        message: 'Invalid or expired OTP. Please request a new one.',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Invalid or expired OTP. Please request a new one.'),
      findsOneWidget,
    );
    expect(find.byType(VerifyEmailChangeOtpScreen), findsOneWidget);
  });

  group('sending the code again', () {
    testWidgets('waits for the timer', (tester) async {
      whenListen(
        countdown,
        const Stream<CountdownState>.empty(),
        initialState: const CountdownState(
          countdownSeconds: 42,
          isActive: true,
        ),
      );
      await open(tester);

      expect(find.text('${en.resendOtp} (42s)'), findsOneWidget);
      await tester.tap(find.text('${en.resendOtp} (42s)'));
      await tester.pump();

      verifyNever(() => profile.add(any(that: isA<ChangeEmailEvent>())));
    });

    testWidgets('asks again with the password typed before', (tester) async {
      await open(tester);

      await tester.tap(find.text(en.resendOtp));
      await tester.pump();

      verify(
        () => profile.add(
          const ChangeEmailEvent(
            newEmail: 'new@example.dz',
            currentPassword: 'Old-pass1',
          ),
        ),
      ).called(1);
    });

    testWidgets('a Google account needs no password', (tester) async {
      await open(tester, password: null, googleId: 'g-1');

      await tester.tap(find.text(en.resendOtp));
      await tester.pump();

      verify(
        () => profile.add(
          const ChangeEmailEvent(
            newEmail: 'new@example.dz',
            currentPassword: '',
          ),
        ),
      ).called(1);
    });

    testWidgets('reopened without the password: typed again first', (
      tester,
    ) async {
      await open(tester, password: null);

      await tester.tap(find.text(en.resendOtp));
      await tester.pumpAndSettle();

      verifyNever(() => profile.add(any(that: isA<ChangeEmailEvent>())));
      expect(
        routes.last.name,
        AppRoutes.changeEmail,
        reason: 'it resent with an empty password, which is always refused',
      );
    });

    testWidgets('sent: the timer restarts', (tester) async {
      await open(tester);
      clearInteractions(countdown);

      states.add(
        const ProfileState(
          requestState: RequestState.loaded,
          message:
              'Email change request submitted. Please check your new email for verification.',
          resendCountdown: 90,
        ),
      );
      await tester.pumpAndSettle();

      verify(() => countdown.add(const StartCountdownEvent(90))).called(1);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await open(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
