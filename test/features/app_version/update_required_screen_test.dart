import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/presentation/screens/update_required_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/platform.dart';
import '../../helpers/pump.dart';
import '../../helpers/routes.dart';

/// "Update required": this app is older than the minimum; the button opens
/// the update link the server gave (the APK download in the pilot).
void main() {
  late RouteLog routes;

  setUp(() => routes = RouteLog());

  Future<void> pump(
    WidgetTester tester,
    AppVersion versions, {
    Locale locale = const Locale('en'),
  }) => pumpPage(
    tester,
    UpdateRequiredScreen(appVersion: versions, userCurrentVersion: '1.1.0'),
    locale: locale,
    routes: routes,
  );

  const versions = AppVersion(
    minimumVersion: '1.2.0',
    currentVersion: '1.3.0',
    updateUrlAndroid: 'https://example.dz/app.apk',
  );

  testWidgets('shows the three versions', (tester) async {
    await pump(tester, versions);

    expect(find.text('Update Required'), findsOneWidget);
    expect(find.text('1.1.0'), findsOneWidget);
    expect(find.text('1.2.0'), findsOneWidget);
    expect(find.text('1.3.0'), findsOneWidget);
  });

  testWidgets('the button opens the server\'s update link', (tester) async {
    await pump(tester, versions);

    await tester.tap(find.text('Update Now'));
    await tester.pumpAndSettle();

    expect(urlLauncher.launched, ['https://example.dz/app.apk']);
  });

  testWidgets('without a link, the APK the server hosts', (tester) async {
    await pump(
      tester,
      const AppVersion(minimumVersion: '1.2.0', currentVersion: '1.3.0'),
    );

    await tester.tap(find.text('Update Now'));
    await tester.pumpAndSettle();

    expect(urlLauncher.launched, [
      '$testHostUrl/downloads/manager.apk',
    ], reason: 'the app is installed directly: a store page has nothing');
  });

  testWidgets(
    'on an iPhone without a link, it says the update can\'t be opened',
    (tester) async {
      await pump(
        tester,
        const AppVersion(minimumVersion: '1.2.0', currentVersion: '1.3.0'),
      );

      await tester.tap(find.text('Update Now'));
      await tester.pumpAndSettle();

      expect(urlLauncher.launched, isEmpty);
      expect(
        find.text(
          'The update can\'t be opened on this device. '
          'Please contact us to get the new version.',
        ),
        findsOneWidget,
        reason: 'the button used to do nothing',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('a link that can\'t be opened says so', (tester) async {
    urlLauncher.canOpen = false;
    await pump(tester, versions);

    await tester.tap(find.text('Update Now'));
    await tester.pumpAndSettle();

    expect(urlLauncher.launched, ['https://example.dz/app.apk']);
    expect(
      find.text(
        'The update can\'t be opened on this device. '
        'Please contact us to get the new version.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the settings are at hand', (tester) async {
    await pump(tester, versions);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(routes.last.name, AppRoutes.settings);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, versions, locale: locale);

      expect(tester.takeException(), isNull);
    });
  }
}
