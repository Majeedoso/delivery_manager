import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/coupons_home_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump.dart';
import '../../../../helpers/readable.dart';
import '../../../../helpers/routes.dart';

/// "Coupons": the three kinds of coupon the manager issues, each its list.
void main() {
  late RouteLog routes;

  setUp(() => routes = RouteLog());

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await pumpPage(
      tester,
      const CouponsHomeScreen(),
      locale: locale,
      themeMode: themeMode,
      routes: routes,
    );
    // The two pictures are read from the app's files
    await settleFiles(tester, rounds: 5);
  }

  testWidgets('each kind opens its list', (tester) async {
    await pump(tester);

    for (final (title, route) in [
      ('Restaurant Coupons', AppRoutes.restaurantCoupons),
      ('Delivery Coupons', AppRoutes.deliveryCoupons),
      ('Global Coupons', AppRoutes.globalCoupons),
    ]) {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(routes.names.last, route, reason: title);
      Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
      await tester.pumpAndSettle();
    }
  });

  // M2: the two pictures had been deleted from the app (an error icon)
  testWidgets('its pictures are there', (tester) async {
    await pump(tester);

    expect(find.byType(Image), findsNWidgets(2));
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  // M17: "Global Coupons" was English in every language
  testWidgets('in the manager\'s language', (tester) async {
    await pump(tester, locale: const Locale('fr'));
    final fr = lookupAppLocalizations(const Locale('fr'));

    expect(find.text(fr.globalCoupons), findsOneWidget);
    expect(find.text('Global Coupons'), findsNothing);
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
