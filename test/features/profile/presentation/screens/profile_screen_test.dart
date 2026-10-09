import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/features/profile/presentation/screens/profile_screen.dart';
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
import 'package:delivery_manager/core/utils/phone_text.dart';

/// "Profile": who is signed in, and the ways to edit the profile, change the
/// email or the password, delete the account or log out.
void main() {
  late MockAuthBloc auth;
  late MockCountdownBloc countdown;
  late RouteLog routes;
  late SharedPreferences prefs;
  final en = lookupAppLocalizations(const Locale('en'));

  const karim = User(
    id: 7,
    name: 'Karim Haddad',
    email: 'karim@example.dz',
    phone: '0550123456',
    role: UserRole.manager,
  );

  setUpAll(registerFallbacks);

  setUp(() async {
    auth = MockAuthBloc();
    countdown = MockCountdownBloc();
    routes = RouteLog();
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(),
    );
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    registerService<SharedPreferences>(prefs);
  });

  Future<void> pump(
    WidgetTester tester, {
    User? user = karim,
    Locale locale = const Locale('en'),
    bool settle = true,
  }) {
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: AuthState(
        requestState: RequestState.loaded,
        user: user,
        isAuthenticated: user != null,
      ),
    );
    return pumpPage(
      tester,
      const ProfileScreen(),
      locale: locale,
      settle: settle,
      routes: routes,
      blocs: [
        BlocProvider<AuthBloc>.value(value: auth),
        BlocProvider<CountdownBloc>.value(value: countdown),
      ],
    );
  }

  Future<void> tapAction(WidgetTester tester, String title) async {
    await scrollTo(tester, find.text(title));
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  testWidgets('who is signed in', (tester) async {
    await pump(tester);

    expect(find.text('Karim Haddad'), findsOneWidget);
    expect(find.text('karim@example.dz'), findsOneWidget);
    expect(find.text(phoneText('0550123456')), findsOneWidget);
  });

  testWidgets('the account type and status are in the app language', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('MANAGER'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);

    await pump(tester, locale: const Locale('fr'));
    expect(find.text('GESTIONNAIRE'), findsOneWidget);
    expect(
      find.text('ACTIF'),
      findsOneWidget,
      reason:
          'the words of the server were shown as they came: MANAGER, ACTIVE',
    );
    expect(find.text('MANAGER'), findsNothing);
  });

  testWidgets('no phone, no phone card', (tester) async {
    await pump(
      tester,
      user: const User(
        id: 7,
        name: 'Karim',
        email: 'karim@example.dz',
        phone: '',
        role: UserRole.manager,
      ),
    );

    expect(find.text(en.phone), findsNothing);
  });

  testWidgets('before the user is known, an animation', (tester) async {
    await pump(tester, user: null, settle: false);

    expect(find.text(en.editProfile), findsNothing);
  });

  testWidgets('edit the profile', (tester) async {
    await pump(tester);

    await tapAction(tester, en.editProfile);

    expect(routes.last.name, AppRoutes.editProfile);
  });

  testWidgets('change the password', (tester) async {
    await pump(tester);

    await tapAction(tester, en.changePassword);

    expect(routes.last.name, AppRoutes.changePassword);
  });

  group('changing the email', () {
    testWidgets('starts with the new address', (tester) async {
      await pump(tester);

      await tapAction(tester, en.changeEmail);

      expect(routes.last.name, AppRoutes.changeEmail);
    });

    testWidgets('a code on its way: straight back to it', (tester) async {
      whenListen(
        countdown,
        const Stream<CountdownState>.empty(),
        initialState: const CountdownState(
          countdownSeconds: 80,
          isActive: true,
        ),
      );
      await prefs.setString('pending_email_change', 'new@example.dz');
      await pump(tester);

      await tapAction(tester, en.changeEmail);

      expect(routes.last.name, AppRoutes.verifyEmailChangeOtp);
      expect(routes.lastArguments, {'newEmail': 'new@example.dz'});
    });

    testWidgets('a code on its way but no address kept: start over', (
      tester,
    ) async {
      whenListen(
        countdown,
        const Stream<CountdownState>.empty(),
        initialState: const CountdownState(
          countdownSeconds: 80,
          isActive: true,
        ),
      );
      await pump(tester);

      await tapAction(tester, en.changeEmail);

      expect(routes.last.name, AppRoutes.changeEmail);
    });
  });

  group('deleting the account', () {
    testWidgets('asks first, then asks for the code', (tester) async {
      await pump(tester);

      await tapAction(tester, en.deleteAccount);
      expect(find.text(en.deleteAccountConfirmation), findsOneWidget);
      await tester.tap(find.text(en.continueButton));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.verifyDeleteAccountOtp);
    });

    testWidgets('cancel keeps it', (tester) async {
      await pump(tester);
      final pages = routes.names.whereType<String>().length;

      await tapAction(tester, en.deleteAccount);
      await tester.tap(find.text(en.cancel));
      await tester.pumpAndSettle();

      expect(routes.names.whereType<String>(), hasLength(pages));
      expect(find.text(en.deleteAccountConfirmation), findsNothing);
    });

    testWidgets('said in the manager\'s language', (tester) async {
      await pump(tester, locale: const Locale('ar'));

      await scrollTo(tester, find.text('حذف الحساب'));

      expect(
        find.text('Delete Account'),
        findsNothing,
        reason: 'it was written in English',
      );
    });
  });

  testWidgets('logging out asks first, then signs out to the login', (
    tester,
  ) async {
    await pump(tester);

    await tapAction(tester, en.logout);
    expect(find.text(en.areYouSureLogout), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, en.logout));
    await tester.pumpAndSettle();

    verify(() => auth.add(any(that: isA<LogoutEvent>()))).called(1);
    expect(routes.last.name, AppRoutes.login);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
