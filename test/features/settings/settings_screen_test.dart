import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/app_config/domain/entities/legal_urls.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_parameters.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_usecase.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_event.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_event.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/fakes.dart';
import '../../helpers/locator.dart';
import '../../helpers/platform.dart';
import '../../helpers/pump.dart';

class _MockLegalUrls extends Mock implements GetLegalUrlsUseCase {}

/// Settings: the language and the theme, the legal pages (in the chosen
/// language), the app's version and a check for a newer one.
void main() {
  late MockLocalizationBloc localization;
  late MockThemeBloc theme;
  late MockAppVersionBloc versions;
  late _MockLegalUrls legalUrls;
  late StreamController<LocalizationState> languages;
  late StreamController<AppVersionState> versionStates;
  final en = lookupAppLocalizations(const Locale('en'));

  Language language(String code) =>
      Language.supportedLanguages.firstWhere((l) => l.code == code);

  const legal = LegalUrls(
    privacyPolicyUrl: 'https://example.dz/privacy?lang=en',
    termsOfServiceUrl: 'https://example.dz/terms?lang=en',
  );

  setUpAll(() {
    registerFallbacks();
    registerFallbackValue(const GetLegalUrlsParameters());
  });

  setUp(() {
    localization = MockLocalizationBloc();
    theme = MockThemeBloc();
    versions = MockAppVersionBloc();
    legalUrls = _MockLegalUrls();
    languages = StreamController<LocalizationState>.broadcast();
    versionStates = StreamController<AppVersionState>.broadcast();
    registerUseCase<GetLegalUrlsUseCase>(legalUrls);
    when(() => legalUrls(any())).thenAnswer((_) async => const Right(legal));
    whenListen(
      theme,
      const Stream<ThemeState>.empty(),
      initialState: const ThemeState(currentTheme: ThemeMode.light),
    );
    whenListen(
      versions,
      versionStates.stream,
      initialState: const AppVersionState(),
    );
    PackageInfo.setMockInitialValues(
      appName: 'Delivery',
      packageName: 'website.sofistem.delivery_manager',
      version: '1.2.0',
      buildNumber: '7',
      buildSignature: '',
    );
  });

  tearDown(() {
    languages.close();
    versionStates.close();
  });

  Future<void> pump(WidgetTester tester, {String code = 'en'}) {
    whenListen(
      localization,
      languages.stream,
      initialState: LocalizationState(
        currentLanguage: language(code),
        requestState: RequestState.loaded,
      ),
    );
    return pumpPage(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<LocalizationBloc>.value(value: localization),
          BlocProvider<ThemeBloc>.value(value: theme),
          BlocProvider<AppVersionBloc>.value(value: versions),
        ],
        child: const SettingsScreen(),
      ),
      locale: Locale(code),
    );
  }

  testWidgets('the language and the theme in use', (tester) async {
    await pump(tester);

    expect(find.textContaining('English'), findsOneWidget);
    expect(find.text(en.light), findsOneWidget);
  });

  testWidgets('another language is chosen from the list', (tester) async {
    await pump(tester);

    await tester.tap(find.text(en.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text(language('fr').nativeName).last);
    await tester.pumpAndSettle();

    verify(
      () => localization.add(ChangeLanguageEvent(language('fr'))),
    ).called(1);
  });

  testWidgets('another theme is chosen from the list', (tester) async {
    await pump(tester);

    await tester.tap(find.text(en.theme));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.dark).last);
    await tester.pumpAndSettle();

    verify(() => theme.add(const ChangeThemeEvent(ThemeMode.dark))).called(1);
  });

  group('the legal pages', () {
    testWidgets('asked for in the language in use, opened outside', (
      tester,
    ) async {
      await pump(tester);

      verify(
        () => legalUrls(const GetLegalUrlsParameters(languageCode: 'en')),
      ).called(1);

      await tester.tap(find.text(en.privacyPolicy));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.termsOfService));
      await tester.pumpAndSettle();

      expect(urlLauncher.launched, [
        'https://example.dz/privacy?lang=en',
        'https://example.dz/terms?lang=en',
      ]);
    });

    testWidgets('asked for again when the language changes', (tester) async {
      await pump(tester);

      languages.add(
        LocalizationState(
          currentLanguage: language('ar'),
          requestState: RequestState.loaded,
        ),
      );
      await tester.pumpAndSettle();

      verify(
        () => legalUrls(const GetLegalUrlsParameters(languageCode: 'ar')),
      ).called(1);
    });

    testWidgets('not loaded: a tap says so', (tester) async {
      when(
        () => legalUrls(any()),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
      await pump(tester);

      await tester.tap(find.text(en.privacyPolicy));
      await tester.pumpAndSettle();

      expect(
        find.text(en.urlNotAvailable),
        findsOneWidget,
        reason: 'the tile did nothing at all',
      );
      expect(urlLauncher.launched, isEmpty);
    });

    testWidgets('only web links are opened', (tester) async {
      when(() => legalUrls(any())).thenAnswer(
        (_) async => const Right(
          LegalUrls(
            privacyPolicyUrl: 'javascript:alert(1)',
            termsOfServiceUrl: 'file:///etc/passwd',
          ),
        ),
      );
      await pump(tester);

      await tester.tap(find.text(en.privacyPolicy));
      await tester.pumpAndSettle();

      expect(urlLauncher.launched, isEmpty);
      expect(find.text(en.urlNotAvailable), findsOneWidget);
    });
  });

  testWidgets('the app\'s version, and the copyright', (tester) async {
    await pump(tester);

    await scrollTo(tester, find.text(en.copyright('${clock.now().year}')));

    expect(find.text('1.2.0'), findsOneWidget);
    expect(find.text(en.copyright('${clock.now().year}')), findsOneWidget);
  });

  group('checking for updates', () {
    Future<void> check(WidgetTester tester) async {
      await pump(tester);
      await scrollTo(tester, find.text(en.checkForUpdates));
      await tester.tap(find.text(en.checkForUpdates));
      await tester.pump();
    }

    AppVersionState checked({
      String minimum = '1.0.0',
      String latest = '1.3.0',
    }) => AppVersionState(
      requestState: RequestState.loaded,
      userCurrentVersion: '1.2.0',
      isVersionSupported: true,
      appVersion: AppVersion(
        minimumVersion: minimum,
        currentVersion: latest,
        updateUrlAndroid: 'https://example.dz/app.apk',
      ),
    );

    testWidgets('asks the server, with a spinner meanwhile', (tester) async {
      await check(tester);

      verify(() => versions.add(const CheckAppVersionEvent())).called(1);
      expect(
        find.text(en.unableToCheckForUpdates),
        findsNothing,
        reason: 'it flashed before the check had even started',
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a newer version can be installed', (tester) async {
      await check(tester);

      versionStates.add(checked());
      await tester.pumpAndSettle();

      expect(find.text('1.2.0'), findsWidgets);
      expect(find.text('1.3.0'), findsOneWidget);
      expect(find.text(en.updateAvailableOptional), findsOneWidget);

      await tester.tap(find.text(en.updateNow));
      await tester.pumpAndSettle();

      expect(urlLauncher.launched, ['https://example.dz/app.apk']);
    });

    testWidgets('without a link, the APK the server hosts', (tester) async {
      await check(tester);

      versionStates.add(
        const AppVersionState(
          requestState: RequestState.loaded,
          userCurrentVersion: '1.2.0',
          isVersionSupported: true,
          appVersion: AppVersion(
            minimumVersion: '1.0.0',
            currentVersion: '1.3.0',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.updateNow));
      await tester.pumpAndSettle();

      expect(urlLauncher.launched, [
        '$testHostUrl/downloads/manager.apk',
      ], reason: 'the app is installed directly, not from a store');
    });

    testWidgets(
      'on an iPhone without a link, it says so and closes the dialog',
      (tester) async {
        await check(tester);

        versionStates.add(
          const AppVersionState(
            requestState: RequestState.loaded,
            userCurrentVersion: '1.2.0',
            isVersionSupported: true,
            appVersion: AppVersion(
              minimumVersion: '1.0.0',
              currentVersion: '1.3.0',
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(en.updateNow));
        await tester.pumpAndSettle();

        expect(urlLauncher.launched, isEmpty);
        expect(find.byType(AlertDialog), findsNothing);
        expect(
          find.text(en.updateLinkUnavailable),
          findsOneWidget,
          reason: 'the button used to do nothing',
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('below the minimum, the update is required', (tester) async {
      await check(tester);

      versionStates.add(checked(minimum: '1.2.1'));
      await tester.pumpAndSettle();

      expect(find.text(en.updateAvailable), findsOneWidget);
      expect(find.text(en.updateNow), findsOneWidget);
    });

    testWidgets('up to date: nothing to install', (tester) async {
      await check(tester);

      versionStates.add(checked(latest: '1.2.0'));
      await tester.pumpAndSettle();

      expect(find.text(en.appUpToDate), findsOneWidget);
      expect(find.text(en.updateNow), findsNothing);
    });

    testWidgets('the server can\'t be asked: said in the manager\'s words', (
      tester,
    ) async {
      await check(tester);

      versionStates.add(
        const AppVersionState(
          requestState: RequestState.loaded,
          isVersionSupported: true,
          message: 'Network error. Please check your internet connection.',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(en.unableToCheckForUpdates), findsOneWidget);

      await tester.tap(find.text(en.cancel));
      await tester.pumpAndSettle();
      expect(find.text(en.unableToCheckForUpdates), findsNothing);
    });
  });

  for (final code in const ['fr', 'ar']) {
    testWidgets('fits a phone in $code', (tester) async {
      await pump(tester, code: code);
      await scrollTo(
        tester,
        find.text(
          lookupAppLocalizations(Locale(code)).copyright('${clock.now().year}'),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
