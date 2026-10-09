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
import 'package:delivery_manager/features/profile/presentation/screens/verify_delete_account_otp_screen.dart';
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

/// Deleting the account: a code is sent to the manager's email on arrival;
/// the right code deletes the account and signs out to the login.
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

  setUpAll(registerFallbacks);

  setUp(() {
    profile = MockProfileBloc();
    auth = MockAuthBloc();
    countdown = MockCountdownBloc();
    states = StreamController<ProfileState>.broadcast();
    routes = RouteLog();
    whenListen(profile, states.stream, initialState: const ProfileState());
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(
        requestState: RequestState.loaded,
        user: User(
          id: 7,
          name: 'Karim',
          email: 'karim@example.dz',
          phone: '0550123456',
          role: UserRole.manager,
        ),
      ),
    );
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
    BlocProvider<ProfileBloc>.value(
      value: profile,
      child: const VerifyDeleteAccountOtpScreen(),
    ),
    locale: locale,
    routes: routes,
    blocs: [
      BlocProvider<AuthBloc>.value(value: auth),
      BlocProvider<CountdownBloc>.value(value: countdown),
    ],
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  List<String> codesSent() => verify(
    () => profile.add(captureAny(that: isA<VerifyDeleteAccountOtpEvent>())),
  ).captured.map((e) => (e as VerifyDeleteAccountOtpEvent).otp).toList();

  testWidgets('sends a code to the manager\'s email on arrival', (
    tester,
  ) async {
    await pump(tester);

    verify(() => profile.add(const SendDeleteAccountOtpEvent())).called(1);
    expect(
      find.text(en.weSentVerificationCodeTo('karim@example.dz')),
      findsOneWidget,
    );
  });

  testWidgets('a code still valid is not sent again', (tester) async {
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(countdownSeconds: 50, isActive: true),
    );

    await pump(tester);

    verifyNever(() => profile.add(const SendDeleteAccountOtpEvent()));
    expect(find.text(en.resendIn(50)), findsOneWidget);
  });

  testWidgets('sent: the resend timer starts', (tester) async {
    await pump(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.loaded,
        message: 'Account deletion OTP sent to your email',
        resendCountdown: 60,
      ),
    );
    await tester.pumpAndSettle();

    verify(() => countdown.add(const StartCountdownEvent(60))).called(1);
  });

  testWidgets('a complete code deletes the account', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(Pinput), '654321');
    await settle(tester);

    expect(codesSent(), ['654321']);
  });

  testWidgets('the button needs six digits', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(Pinput), '654');
    await settle(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, en.deleteAccount));
    await settle(tester);

    expect(find.text(en.pleaseEnterValid6DigitOtp), findsOneWidget);
    verifyNever(
      () => profile.add(any(that: isA<VerifyDeleteAccountOtpEvent>())),
    );
  });

  testWidgets('a code copied from the email is filled in and sent once', (
    tester,
  ) async {
    await pump(tester);

    clipboard.text = 'Your code: 246810';
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);

    expect(codesSent(), [
      '246810',
    ], reason: 'a delayed second send went out after the first');
  });

  testWidgets('deleted: signed out, back to the login', (tester) async {
    await pump(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.loaded,
        message: 'Account deleted successfully',
      ),
    );
    await tester.pumpAndSettle();

    verify(() => countdown.add(const StopCountdownEvent())).called(1);
    verify(() => auth.add(any(that: isA<LogoutEvent>()))).called(1);
    expect(routes.last.name, AppRoutes.login);
  });

  testWidgets('a wrong code says why and keeps the account', (tester) async {
    await pump(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.error,
        message: 'Invalid or expired OTP',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid or expired OTP'), findsOneWidget);
    verifyNever(() => auth.add(any(that: isA<LogoutEvent>())));
  });

  testWidgets('resend, once the timer is over', (tester) async {
    await pump(tester);
    clearInteractions(profile);

    await scrollTo(tester, find.text(en.resendOtp));
    await tester.tap(find.text(en.resendOtp));
    await tester.pump();

    verify(() => profile.add(const SendDeleteAccountOtpEvent())).called(1);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
