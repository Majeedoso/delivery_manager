import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_email_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// "Change email": the new address and the password (none for a Google
/// account), then on to the code sent to the new address.
void main() {
  late MockProfileBloc profile;
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late StreamController<ProfileState> states;
  late RouteLog routes;
  late SharedPreferences prefs;
  final en = lookupAppLocalizations(const Locale('en'));

  const karim = User(
    id: 7,
    name: 'Karim',
    email: 'karim@example.dz',
    phone: '0550123456',
    role: UserRole.manager,
    hasPassword: true,
  );

  setUpAll(registerFallbacks);

  setUp(() async {
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
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    registerService<SharedPreferences>(prefs);
  });

  tearDown(() => states.close());

  Future<void> pump(
    WidgetTester tester, {
    User user = karim,
    Locale locale = const Locale('en'),
  }) {
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: AuthState(requestState: RequestState.loaded, user: user),
    );
    return pumpPage(
      tester,
      BlocProvider<ProfileBloc>.value(
        value: profile,
        child: const ChangeEmailScreen(),
      ),
      locale: locale,
      routes: routes,
      blocs: [
        BlocProvider<AuthBloc>.value(value: auth),
        BlocProvider<CountdownBloc>.value(value: countdown),
      ],
    );
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> submit(
    WidgetTester tester, {
    String email = 'new@example.dz',
    String? password = 'Old-pass1',
  }) async {
    await tester.enterText(field(en.newEmailAddress), email);
    if (password != null) {
      await tester.enterText(field(en.currentPassword), password);
    }
    await tester.tap(find.widgetWithText(ElevatedButton, en.changeEmail));
    await tester.pump();
  }

  testWidgets('sends the new address with the password, trimmed', (
    tester,
  ) async {
    await pump(tester);

    await submit(tester, email: '  new@example.dz ');

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
    await pump(
      tester,
      user: const User(
        id: 7,
        name: 'Karim',
        email: 'karim@gmail.com',
        phone: '',
        role: UserRole.manager,
        googleId: 'g-123',
      ),
    );

    expect(field(en.currentPassword), findsNothing);
    await submit(tester, password: null);

    verify(
      () => profile.add(
        const ChangeEmailEvent(newEmail: 'new@example.dz', currentPassword: ''),
      ),
    ).called(1);
  });

  group('checks before sending', () {
    testWidgets('an address, a valid one', (tester) async {
      await pump(tester);

      await submit(tester, email: '');
      expect(find.text(en.pleaseEnterEmail), findsOneWidget);

      await submit(tester, email: 'karim@');
      expect(find.text(en.pleaseEnterValidEmail), findsOneWidget);

      verifyNever(() => profile.add(any(that: isA<ChangeEmailEvent>())));
    });

    testWidgets('another address than the current one', (tester) async {
      await pump(tester);

      await submit(tester, email: 'Karim@Example.dz');

      expect(
        find.text(en.newEmailMustBeDifferent),
        findsOneWidget,
        reason: 'this page never has the profile: the check never ran',
      );
      verifyNever(() => profile.add(any(that: isA<ChangeEmailEvent>())));
    });

    testWidgets('the password', (tester) async {
      await pump(tester);

      await submit(tester, password: '');

      expect(find.text(en.pleaseEnterPassword), findsOneWidget);
    });
  });

  testWidgets('code sent: the timer starts, on to the code', (tester) async {
    await pump(tester);
    await tester.enterText(field(en.newEmailAddress), 'new@example.dz');
    await tester.enterText(field(en.currentPassword), 'Old-pass1');

    states.add(
      const ProfileState(
        requestState: RequestState.loaded,
        message: 'Email change request submitted.',
        resendCountdown: 90,
      ),
    );
    await tester.pumpAndSettle();

    verify(() => countdown.add(const StartCountdownEvent(120))).called(1);
    expect(prefs.getString('pending_email_change'), 'new@example.dz');
    expect(routes.last.name, AppRoutes.verifyEmailChangeOtp);
    expect(routes.lastArguments, {
      'newEmail': 'new@example.dz',
      'currentPassword': 'Old-pass1',
    }, reason: 'resending the code needs the password again');
  });

  testWidgets('a refusal says why', (tester) async {
    await pump(tester);

    states.add(
      const ProfileState(
        requestState: RequestState.error,
        message: 'This email address is already registered.',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('This email address is already registered.'),
      findsOneWidget,
    );
    expect(routes.names, isNot(contains(AppRoutes.verifyEmailChangeOtp)));
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
