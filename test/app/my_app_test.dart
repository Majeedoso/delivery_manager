import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/services/notification_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/account_status_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/splash_screen.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/features/home/presentation/screens/main_screen.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/localization/presentation/screens/first_run_language_screen.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';
import 'package:delivery_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fakes.dart';
import '../helpers/locator.dart';
import '../helpers/pump.dart';

/// MyApp is the shell every screen lives in: it waits for the first-run check,
/// picks the first screen, applies language and theme, sends a suspended
/// manager back to sign in, and syncs the FCM token when the app comes back.
/// And the start of a working day: splash, then the main screen.
void main() {
  late MockLocalizationBloc localization;
  late MockThemeBloc theme;
  late MockAuthBloc auth;
  late MockAppVersionBloc appVersion;
  late MockLoadCredentialsUseCase loadCredentials;

  final arabic = Language.supportedLanguages.firstWhere((l) => l.code == 'ar');

  setUpAll(registerFallbacks);

  setUp(() {
    localization = MockLocalizationBloc();
    theme = MockThemeBloc();
    auth = MockAuthBloc();
    appVersion = MockAppVersionBloc();
    loadCredentials = MockLoadCredentialsUseCase();
    final countdown = MockCountdownBloc();

    whenListen(
      theme,
      const Stream<ThemeState>.empty(),
      initialState: const ThemeState(currentTheme: ThemeMode.light),
    );
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(),
    );
    whenListen(
      countdown,
      const Stream<CountdownState>.empty(),
      initialState: const CountdownState(),
    );
    whenListen(
      appVersion,
      const Stream<AppVersionState>.empty(),
      initialState: const AppVersionState(
        requestState: RequestState.loaded,
        appVersion: AppVersion(
          minimumVersion: '1.0.0',
          currentVersion: '1.0.0',
        ),
      ),
    );
    when(
      () => loadCredentials(any()),
    ).thenAnswer((_) async => const Right({'email': null, 'rememberMe': null}));

    registerBloc<LocalizationBloc>(localization);
    registerBloc<ThemeBloc>(theme);
    registerBloc<AuthBloc>(auth);
    registerBloc<CountdownBloc>(countdown);
    registerBloc<AppVersionBloc>(appVersion);
    registerUseCase<LoadCredentialsUseCase>(loadCredentials);
  });

  void language(LocalizationState state) => whenListen(
    localization,
    const Stream<LocalizationState>.empty(),
    initialState: state,
  );

  const firstRun = LocalizationState(
    firstRunCheckCompleted: true,
    isFirstRun: true,
    requestState: RequestState.loaded,
  );

  Future<void> pumpApp(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pump();
  }

  testWidgets('shows only the loader until the first-run check is done', (
    tester,
  ) async {
    language(const LocalizationState(firstRunCheckCompleted: false));

    await pumpApp(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(FirstRunLanguageScreen), findsNothing);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('a first run starts on the language choice', (tester) async {
    language(firstRun);

    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.byType(FirstRunLanguageScreen), findsOneWidget);
    expect(find.text('Choose your language'), findsOneWidget);
  });

  testWidgets('later runs start on the splash screen', (tester) async {
    language(
      const LocalizationState(
        firstRunCheckCompleted: true,
        requestState: RequestState.loaded,
      ),
    );

    await pumpApp(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SplashScreen), findsOneWidget);

    // Leave the splash screen so its startup checks and timers stop.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Arabic lays the app out right to left', (tester) async {
    language(firstRun.copyWith(currentLanguage: arabic));

    await pumpApp(tester);
    await tester.pumpAndSettle();

    final screen = tester.element(find.byType(FirstRunLanguageScreen));
    expect(Directionality.of(screen), TextDirection.rtl);
    expect(Localizations.localeOf(screen), const Locale('ar'));
    expect(find.text('اختر لغتك'), findsOneWidget);
  });

  testWidgets('a calendar\'s week begins on Sunday in every language', (
    tester,
  ) async {
    // Left to Flutter it begins on Saturday in Arabic and on Monday in French
    for (final spoken in Language.supportedLanguages) {
      language(firstRun.copyWith(currentLanguage: spoken));

      await pumpApp(tester);
      await tester.pumpAndSettle();

      final screen = tester.element(find.byType(FirstRunLanguageScreen));
      expect(Localizations.localeOf(screen), Locale(spoken.code));
      expect(
        MaterialLocalizations.of(screen).firstDayOfWeekIndex,
        DateTime.sunday % DateTime.daysPerWeek,
        reason: spoken.code,
      );
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('the recent-apps screen shows the app\'s name in its language', (
    tester,
  ) async {
    language(firstRun.copyWith(currentLanguage: arabic));

    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(
      tester.widgetList<Title>(find.byType(Title)).map((title) => title.title),
      ['تطبيق المدير'],
    );
  });

  testWidgets('the theme follows the saved choice', (tester) async {
    language(firstRun);
    whenListen(
      theme,
      const Stream<ThemeState>.empty(),
      initialState: const ThemeState(currentTheme: ThemeMode.dark),
    );

    await pumpApp(tester);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets(
    'a manager suspended at work is sent to sign in, once per 3 seconds',
    (tester) async {
      ignoreOverflowFromTestFont();
      language(firstRun);
      await pumpApp(tester);
      await tester.pumpAndSettle();

      accountSuspendedEvents.add(null);
      await tester.pumpAndSettle();
      expect(
        find.byType(LoginScreen),
        findsOneWidget,
        reason: 'every request answers 403: the app used to stay where it was',
      );
      expect(find.byType(FirstRunLanguageScreen), findsNothing);
      final firstLogin = tester.state(find.byType(LoginScreen));

      accountSuspendedEvents.add(null);
      await tester.pumpAndSettle();
      expect(
        tester.state(find.byType(LoginScreen)),
        same(firstLogin),
        reason: 'several failing requests at once must not stack sign-in pages',
      );

      await tester.pump(const Duration(seconds: 3));
      accountSuspendedEvents.add(null);
      await tester.pumpAndSettle();
      expect(
        tester.state(find.byType(LoginScreen)),
        isNot(same(firstLogin)),
        reason: 'after 3 seconds a new suspension is handled again',
      );
      await tester.pump(const Duration(seconds: 3));
    },
  );

  testWidgets('a name the route table does not know shows "page not found"', (
    tester,
  ) async {
    language(firstRun);
    await pumpApp(tester);
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pushNamed('/no-such-page');
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'MaterialApp threw without onUnknownRoute (D11)',
    );
    expect(find.text('Page Not Found'), findsOneWidget);
  });

  testWidgets('coming back to the app sends the FCM token again', (
    tester,
  ) async {
    // Real FCM tokens are long; the service logs their first 20 characters.
    const fcmToken =
        'fcm-device-1:APA91bHPRgkF3JUikC4ENAHEeMrd41Zxv3hVZjC9KtT8';
    final tokens = MockTokenRepository();
    final authApi = MockAuthRemoteDataSource();
    when(() => tokens.getToken()).thenAnswer((_) async => const Right('abc'));
    when(() => authApi.updateFcmToken(any())).thenAnswer((_) async {});
    registerService<BaseTokenRepository>(tokens);
    registerService<BaseAuthRemoteDataSource>(authApi);
    NotificationService.fetchFcmToken = () async => fcmToken;
    language(firstRun);
    await pumpApp(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    verify(() => authApi.updateFcmToken(fcmToken)).called(1);
  });

  group('a returning manager', () {
    final account = User(
      id: 1,
      name: 'Karim Haddad',
      email: 'karim@example.dz',
      phone: '0550123456',
      role: UserRole.manager,
      status: 'active',
      emailVerifiedAt: DateTime.utc(2026, 1, 10),
    );

    Future<void> startTheDay(WidgetTester tester, User user) async {
      // Every bloc is mocked except the splash's, which runs its checklist for
      // real on the platform fakes: online, version fine, permissions given
      language(
        const LocalizationState(
          firstRunCheckCompleted: true,
          requestState: RequestState.loaded,
        ),
      );
      final answers = StreamController<AuthState>.broadcast();
      addTearDown(answers.close);
      whenListen(auth, answers.stream, initialState: const AuthState());
      when(() => auth.add(any(that: isA<CheckAuthStatusEvent>()))).thenAnswer(
        (_) => answers.add(
          AuthState(
            requestState: RequestState.loaded,
            isAuthenticated: true,
            user: user,
          ),
        ),
      );
      whenListen(
        appVersion,
        const Stream<AppVersionState>.empty(),
        initialState: const AppVersionState(
          requestState: RequestState.loaded,
          isVersionSupported: true,
          userCurrentVersion: '1.2.0',
          appVersion: AppVersion(
            minimumVersion: '1.0.0',
            currentVersion: '1.2.0',
          ),
        ),
      );
      SharedPreferences.setMockInitialValues({});
      registerService<SharedPreferences>(await SharedPreferences.getInstance());

      await pumpApp(tester);
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    testWidgets('goes from the splash to the main screen', (tester) async {
      ignoreOverflowFromTestFont();
      await startTheDay(tester, account);

      verify(() => auth.add(any(that: isA<CheckAuthStatusEvent>()))).called(1);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(MainScreen), findsOneWidget);

      // Leave the app so the main screen's timers stop
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('still waiting for approval lands on the account status page', (
      tester,
    ) async {
      ignoreOverflowFromTestFont();
      await startTheDay(
        tester,
        User(
          id: 1,
          name: 'Karim Haddad',
          email: 'karim@example.dz',
          phone: '0550123456',
          role: UserRole.manager,
          status: 'pending_approval',
          emailVerifiedAt: DateTime.utc(2026, 1, 10),
        ),
      );

      expect(find.byType(AccountStatusScreen), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
