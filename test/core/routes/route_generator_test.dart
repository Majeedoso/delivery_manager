import 'dart:io';

import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/routes/route_generator.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump.dart';
import '../../helpers/routes.dart';

/// Every screen is reached by name through the route table. A wrong argument
/// must show a readable page rather than crash, and a screen's own `route`
/// constant must be the name the table knows, or pushing it lands on "page
/// not found".
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  /// Pushes [route] with [arguments] through the real table.
  Future<void> open(
    WidgetTester tester,
    String route, [
    Object? arguments,
    Locale locale = const Locale('en'),
  ]) async {
    await pumpPage(
      tester,
      const SizedBox(),
      onGenerateRoute: appRoute,
      locale: locale,
    );
    navigatorKey.currentState!.pushNamed(route, arguments: arguments);
    await tester.pumpAndSettle();
  }

  group('a route opened without the arguments it needs', () {
    final cases = <String, (String, Object?, String)>{
      'email code with nothing': (
        AppRoutes.verifyEmailOtp,
        null,
        l10n.invalidRouteArguments,
      ),
      'email change code with nothing': (
        AppRoutes.verifyEmailChangeOtp,
        null,
        l10n.invalidRouteArguments,
      ),
      'update required with nothing': (
        AppRoutes.updateRequired,
        null,
        l10n.invalidRouteArguments,
      ),
      'update required without the version': (
        AppRoutes.updateRequired,
        <String, dynamic>{'userCurrentVersion': '1.0.0'},
        l10n.invalidAppVersionArgument,
      ),
      'password reset with a non-text map': (
        AppRoutes.resetPasswordUnauthenticated,
        <String, dynamic>{'email': 'karim@example.dz', 'otp': 123456},
        l10n.invalidRouteArguments,
      ),
      'an amount\'s details with nothing': (
        AppRoutes.driverDebtDetails,
        null,
        l10n.invalidRouteArguments,
      ),
      // It cast whatever came as an amount: the page broke
      'an amount\'s details with something else': (
        AppRoutes.driverDebtDetails,
        <String, dynamic>{'item': 'Pizzeria Le Phare', 'period': 'all'},
        l10n.invalidRouteArguments,
      ),
      'a settings category with nothing': (
        AppRoutes.dashboardCategory,
        null,
        l10n.invalidRouteArguments,
      ),
      for (final route in [
        AppRoutes.statisticsMoneyDriverDetail,
        AppRoutes.statisticsMoneyRestaurantDetail,
        AppRoutes.statisticsPerformanceDriverDetail,
        AppRoutes.statisticsPerformanceRestaurantDetail,
      ]) ...{
        '$route with nothing': (route, null, l10n.invalidRouteArguments),
        // It cast the id and the name: a map without them broke the page
        '$route without its id': (
          route,
          <String, dynamic>{'name': 'Yacine Bouzid'},
          l10n.invalidRouteArguments,
        ),
      },
    };

    cases.forEach((name, expected) {
      testWidgets('$name explains the problem', (tester) async {
        final (route, arguments, message) = expected;

        await open(tester, route, arguments);

        expect(tester.takeException(), isNull);
        expect(find.text(message), findsOneWidget);
      });
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('says so in ${locale.languageCode}', (tester) async {
        final words = lookupAppLocalizations(locale);

        for (final (route, arguments, message) in [
          (AppRoutes.verifyEmailOtp, null, words.invalidRouteArguments),
          (AppRoutes.driverDebtDetails, null, words.invalidRouteArguments),
          (
            AppRoutes.updateRequired,
            <String, dynamic>{'userCurrentVersion': '1.0.0'},
            words.invalidAppVersionArgument,
          ),
        ]) {
          await open(tester, route, arguments, locale);

          expect(tester.takeException(), isNull);
          expect(find.text(message), findsOneWidget, reason: route);
          expect(message, isNot(l10n.invalidRouteArguments));
        }
      });
    }
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('an unknown route says so in ${locale.languageCode}', (
      tester,
    ) async {
      final words = lookupAppLocalizations(locale);

      await open(tester, '/no-such-page', null, locale);

      expect(tester.takeException(), isNull);
      expect(find.text(words.pageNotFound), findsOneWidget);
      expect(words.pageNotFound, isNot(l10n.pageNotFound));
    });
  }

  testWidgets('an unknown route shows "page not found"', (tester) async {
    await open(tester, '/no-such-page');

    expect(tester.takeException(), isNull);
    expect(find.text(l10n.pageNotFound), findsOneWidget);
  });

  group('names', () {
    final table = RouteGenerator.generateRoutes().keys.toSet();

    /// The names in app_routes.dart, read from the file (Dart has no way to
    /// list a class's constants).
    final declared = {
      for (final match in RegExp(
        r'''static const String (\w+)\s*=\s*['"]([^'"]+)['"]''',
      ).allMatches(File('lib/core/routes/app_routes.dart').readAsStringSync()))
        match[1]!: match[2]!,
    };

    test('every name in AppRoutes opens a page', () {
      expect(declared, isNotEmpty);
      expect(
        declared.entries
            .where((route) => !table.contains(route.value))
            .map((route) => route.key),
        isEmpty,
        reason: 'pushing these lands on "page not found"',
      );
    });

    // The amount's details called itself "/driver_debt_details", a name the
    // table does not know
    test('each screen\'s own route constant is a name the table knows', () {
      final unknown = <String>[];
      final own = RegExp(
        r'''static const String route(?:Name)?\s*=\s*['"](/[^'"]+)['"]''',
      );
      for (final file in Directory('lib/features').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        for (final match in own.allMatches(file.readAsStringSync())) {
          if (!table.contains(match[1])) {
            unknown.add('${match[1]} in ${file.path}');
          }
        }
      }

      expect(unknown, isEmpty);
    });
  });
}
