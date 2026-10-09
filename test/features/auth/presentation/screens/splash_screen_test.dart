import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// The first screen of every start. It shows the splash checklist's step
/// (internet, version, sign-in), offers a way out of each
/// blocked step, and once the sign-in check answers, opens the right screen.
///
/// Its spinner turns forever, so these tests pump by hand.
void main() {
  late MockSplashBloc splash;
  late MockAuthBloc auth;
  late MockAppVersionBloc appVersion;
  late StreamController<SplashState> steps;
  late StreamController<AuthState> answers;
  late RouteLog routes;

  SplashState at(
    SplashStep step, {
    RequestState requestState = RequestState.loading,
    String? statusMessage,
    String? errorMessage,
  }) => SplashState(
    requestState: requestState,
    currentStep: step,
    statusMessage: statusMessage ?? step.name,
    hasInternetConnection: true,
    internetCheckCompleted: true,
    versionCheckCompleted: true,
    errorMessage: errorMessage,
  );

  final checkingSignIn = at(SplashStep.checkingAuthentication);
  const offline = SplashState(
    requestState: RequestState.error,
    currentStep: SplashStep.noInternet,
    statusMessage: 'noInternetConnection',
    internetCheckCompleted: true,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    splash = MockSplashBloc();
    auth = MockAuthBloc();
    appVersion = MockAppVersionBloc();
    steps = StreamController<SplashState>.broadcast();
    answers = StreamController<AuthState>.broadcast();
    routes = RouteLog();
    whenListen(splash, steps.stream, initialState: const SplashState());
    whenListen(auth, answers.stream, initialState: const AuthState());
    whenListen(
      appVersion,
      const Stream<AppVersionState>.empty(),
      initialState: const AppVersionState(),
    );
  });

  tearDown(() {
    steps.close();
    answers.close();
  });

  Future<void> pump(
    WidgetTester tester, {
    SplashState? state,
    Locale locale = const Locale('en'),
  }) async {
    if (state != null) {
      whenListen(splash, steps.stream, initialState: state);
    }
    await pumpPage(
      tester,
      const SplashScreen(),
      locale: locale,
      settle: false,
      routes: routes,
      blocs: [
        BlocProvider<SplashBloc>.value(value: splash),
        BlocProvider<AuthBloc>.value(value: auth),
        BlocProvider<AppVersionBloc>.value(value: appVersion),
      ],
    );
  }

  /// Lets a navigation run to its end (the spinner never settles).
  Future<void> settleNavigation(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('starts the checklist on arrival', (tester) async {
    await pump(tester);

    verify(() => splash.add(const InitializeAppEvent())).called(1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('says which step it is on', (tester) async {
    await pump(tester, state: checkingSignIn);

    expect(find.text('Checking authentication...'), findsOneWidget);
  });

  group('the internet', () {
    testWidgets('offline: explains and retries', (tester) async {
      await pump(tester, state: offline);

      expect(
        find.text('Please check your internet connection and try again.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => splash.add(const RetryInitializationEvent())).called(1);
    });

    testWidgets('a check with no answer after 30 seconds offers retry', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Retry'), findsNothing);

      await tester.pump(const Duration(seconds: 30));

      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('once the sign-in check answers', () {
    AuthState signedIn(UserModel user) => AuthState(
      requestState: RequestState.loaded,
      isAuthenticated: true,
      user: user,
    );

    testWidgets('a signed-in manager opens the app', (tester) async {
      await pump(tester, state: checkingSignIn);

      answers.add(signedIn(UserModel.fromJson(userJson())));
      await settleNavigation(tester);

      expect(routes.last.name, AppRoutes.main);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('an email still to verify opens the account status', (
      tester,
    ) async {
      await pump(tester, state: checkingSignIn);

      answers.add(
        signedIn(UserModel.fromJson(userJson(emailVerifiedAt: null))),
      );
      await settleNavigation(tester);

      expect(routes.last.name, AppRoutes.accountStatus);
    });

    testWidgets('nobody signed in opens login', (tester) async {
      await pump(tester, state: checkingSignIn);

      answers.add(const AuthState(requestState: RequestState.loaded));
      await settleNavigation(tester);

      expect(routes.last.name, AppRoutes.login);
    });

    testWidgets('a failed check opens login', (tester) async {
      await pump(tester, state: checkingSignIn);

      answers.add(
        const AuthState(requestState: RequestState.error, message: 'boom'),
      );
      await settleNavigation(tester);

      expect(routes.last.name, AppRoutes.login);
    });

    testWidgets('before the checklist gets there, an answer is ignored', (
      tester,
    ) async {
      await pump(tester, state: at(SplashStep.checkingVersion));

      answers.add(signedIn(UserModel.fromJson(userJson())));
      await settleNavigation(tester);

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(routes.names, isNot(contains(AppRoutes.main)));
    });
  });

  // Decision 1 of manager_suite_report.md: no step asks for notifications. A
  // failed start read "Notifications are required for this app" while the
  // permission was not known yet
  testWidgets('a failed start says so, and nothing of notifications', (
    tester,
  ) async {
    await pump(
      tester,
      state: const SplashState(
        requestState: RequestState.error,
        currentStep: SplashStep.error,
        statusMessage: 'initializationFailed',
        hasInternetConnection: true,
        internetCheckCompleted: true,
        versionCheckCompleted: true,
      ),
    );

    expect(find.text('Initialization failed'), findsOneWidget);
    expect(find.text('Notifications are required for this app'), findsNothing);
    expect(find.text('Enable Notifications'), findsNothing);
  });

  testWidgets('an unsupported version opens the update page', (tester) async {
    const version = AppVersion(
      minimumVersion: '1.2.0',
      currentVersion: '1.3.0',
    );
    whenListen(
      appVersion,
      const Stream<AppVersionState>.empty(),
      initialState: const AppVersionState(
        requestState: RequestState.loaded,
        appVersion: version,
        userCurrentVersion: '1.0.0',
        isVersionSupported: false,
      ),
    );
    await pump(tester);

    steps.add(
      at(
        SplashStep.versionUpdateRequired,
        requestState: RequestState.error,
      ).copyWith(isVersionSupported: false),
    );
    await settleNavigation(tester);

    expect(routes.last.name, AppRoutes.updateRequired);
    expect(routes.lastArguments, {
      'appVersion': version,
      'userCurrentVersion': '1.0.0',
    });
  });

  testWidgets('settings', (tester) async {
    await pump(tester, state: offline);

    await tester.tap(find.byIcon(Icons.settings));
    await settleNavigation(tester);

    expect(routes.last.name, AppRoutes.settings);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      for (final state in [offline, checkingSignIn]) {
        await pump(tester, state: state, locale: locale);
        expect(tester.takeException(), isNull, reason: state.currentStep.name);
      }
    });
  }
}
