import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/home/presentation/screens/main_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump.dart';
import '../../helpers/readable.dart';
import '../../helpers/routes.dart';

/// The manager's home: a door to each part of the app, while signed in.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  late MockAuthBloc auth;
  late StreamController<AuthState> states;

  const signedIn = AuthState(
    requestState: RequestState.loaded,
    user: User(
      id: 1,
      name: 'Karim Haddad',
      email: 'karim@example.dz',
      phone: '0550123456',
      role: UserRole.manager,
      status: 'active',
    ),
    isAuthenticated: true,
  );

  setUp(() {
    auth = MockAuthBloc();
    states = StreamController<AuthState>.broadcast();
  });

  tearDown(() => states.close());

  Future<void> pump(
    WidgetTester tester, {
    AuthState state = signedIn,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    RouteLog? routes,
  }) {
    whenListen(auth, states.stream, initialState: state);
    return pumpPage(
      tester,
      const MainScreen(),
      locale: locale,
      themeMode: themeMode,
      routes: routes,
      blocs: [BlocProvider<AuthBloc>.value(value: auth)],
    );
  }

  testWidgets('each door opens its part of the app', (tester) async {
    final routes = RouteLog();
    await pump(tester, routes: routes);

    for (final (door, route) in [
      (en.bank, AppRoutes.bank),
      (en.statistics, AppRoutes.statistics),
      (en.coupons, AppRoutes.coupons),
      (en.userManagement, AppRoutes.users),
      (en.dashboard, AppRoutes.dashboard),
      // Decision 4 of manager_suite_report.md: no page for them
      (en.deliveryAreas, AppRoutes.deliveryAreas),
      (en.profile, AppRoutes.profile),
      (en.settings, AppRoutes.settings),
      (en.aboutApp, AppRoutes.about),
    ]) {
      await tester.ensureVisible(find.text(door));
      await tester.pumpAndSettle();
      await tester.tap(find.text(door));
      await tester.pumpAndSettle();

      expect(routes.last.name, route, reason: door);
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
    }
  });

  // M45: three doors were named in English whatever the language
  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('every door named in ${locale.languageCode}', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      await pump(tester, locale: locale);

      for (final door in [
        l10n.coupons,
        l10n.userManagement,
        l10n.dashboard,
        l10n.deliveryAreas,
      ]) {
        expect(find.text(door), findsOneWidget, reason: door);
      }
      for (final english in [
        'Coupons',
        'User Management',
        'Dashboard',
        'Delivery Zones',
      ]) {
        if (english == l10n.coupons) continue; // French says "Coupons" too
        expect(find.text(english), findsNothing, reason: english);
      }
    });
  }

  testWidgets('signed out: back to the sign-in page', (tester) async {
    final routes = RouteLog();
    await pump(tester, routes: routes);

    states.add(
      const AuthState(
        requestState: RequestState.loaded,
        isAuthenticated: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(routes.last.name, AppRoutes.login);
  });

  testWidgets('no account read: says so', (tester) async {
    await pump(
      tester,
      state: const AuthState(requestState: RequestState.loading),
    );

    expect(find.text(en.noUserDataAvailable), findsOneWidget);
  });

  testWidgets('can be read in dark mode', (tester) async {
    await pump(tester, themeMode: ThemeMode.dark);

    expectReadable(tester);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
