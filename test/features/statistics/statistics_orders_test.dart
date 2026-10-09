import 'package:clock/clock.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_restaurants_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/locator.dart';
import '../../helpers/pump.dart';
import '../../helpers/readable.dart';
import '../../helpers/routes.dart';

/// The orders pages: the orders placed in some days by where each is now,
/// and the drivers and restaurants, each opening its performance.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  const ordersPath = '/manager/statistics/orders';
  const driversPath = '/manager/drivers';
  const restaurantsPath = '/manager/restaurants';
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend()
      ..reply('GET', ordersPath, body: orderStatisticsJson())
      ..reply(
        'GET',
        driversPath,
        body: managerDriversJson([managerDriverJson()]),
      )
      ..reply(
        'GET',
        restaurantsPath,
        body: managerRestaurantsJson([
          managerRestaurantJson(isOpen: true),
          managerRestaurantJson(id: 9, name: 'Tacos Hydra'),
        ]),
      );
    registerService<Dio>(testDio(backend));
  });

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    RouteLog? routes,
  }) => withClock(
    Clock.fixed(testNow),
    () => pumpPage(
      tester,
      page,
      locale: locale,
      themeMode: themeMode,
      routes: routes,
    ),
  );

  /// The number on the line of [label].
  Finder countOf(String label, String count) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Card)),
    matching: find.text(count),
  );

  group('the overview', () {
    testWidgets('this week by default: since Sunday', (tester) async {
      await pump(tester, const StatisticsOrdersOverviewScreen());

      expect(backend.last('GET', ordersPath).query, {
        'date_from': '2026-09-27',
        'date_to': '2026-09-30',
      });
    });

    testWidgets('each line its number', (tester) async {
      await pump(tester, const StatisticsOrdersOverviewScreen());

      for (final (label, count) in [
        (en.ordersPlaced, '12'),
        (en.ordersPendingVerification, '1'),
        (en.ordersAcceptedByRestaurant, '2'),
        (en.ordersRejectedByOperator, '1'),
        (en.ordersAcceptedByDriver, '2'),
        (en.delivered, '3'),
      ]) {
        await tester.scrollUntilVisible(
          find.text(label),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(countOf(label, count), findsOneWidget, reason: label);
      }
    });

    testWidgets('another period asks for its days', (tester) async {
      await pump(tester, const StatisticsOrdersOverviewScreen());

      await withClock(Clock.fixed(testNow), () async {
        await tester.tap(find.byType(DropdownButton2<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(en.today).last);
        await tester.pumpAndSettle();
      });

      expect(backend.last('GET', ordersPath).query, {
        'date_from': '2026-09-30',
        'date_to': '2026-09-30',
      });
    });

    testWidgets('not read: says so, and asks again', (tester) async {
      backend.reply('GET', ordersPath, status: 500, body: htmlErrorPage);
      await pump(tester, const StatisticsOrdersOverviewScreen());
      expect(find.text(en.errorLoadingStatistics), findsOneWidget);

      backend.reply('GET', ordersPath, body: orderStatisticsJson());
      await tester.tap(find.text(en.tryAgain));
      await tester.pumpAndSettle();

      expect(countOf(en.ordersPlaced, '12'), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsOrdersOverviewScreen(),
        themeMode: ThemeMode.dark,
      );

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsOrdersOverviewScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the drivers', () {
    testWidgets('the first ten; each opens its performance', (tester) async {
      final routes = RouteLog();
      await pump(tester, const StatisticsOrdersDriversScreen(), routes: routes);
      expect(backend.last('GET', driversPath).query, {
        'page': 1,
        'per_page': 10,
      });

      await tester.tap(find.text('Yacine Bouzid'));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.statisticsPerformanceDriverDetail);
      expect(routes.lastArguments, {'id': 25, 'name': 'Yacine Bouzid'});
    });

    // M39: the next pages were read from where the server does not send them
    testWidgets('the next ten, at the bottom', (tester) async {
      backend.replyInTurn('GET', driversPath, [
        FakeReply(200, managerDriversJson([managerDriverJson()], lastPage: 2)),
        FakeReply(
          200,
          managerDriversJson(
            [managerDriverJson(id: 26, name: 'Sofiane Amrani')],
            currentPage: 2,
            lastPage: 2,
          ),
        ),
      ]);
      await pump(tester, const StatisticsOrdersDriversScreen());

      await tester.tap(find.text(en.loadMore));
      await tester.pumpAndSettle();

      expect(find.text('Yacine Bouzid'), findsOneWidget);
      expect(find.text('Sofiane Amrani'), findsOneWidget);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsOrdersDriversScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the restaurants', () {
    testWidgets('each, open or closed now, opens its performance', (
      tester,
    ) async {
      final routes = RouteLog();
      await pump(
        tester,
        const StatisticsOrdersRestaurantsScreen(),
        routes: routes,
      );

      expect(find.text(en.open), findsOneWidget);
      expect(find.text(en.closed), findsOneWidget);

      await tester.tap(find.text('Tacos Hydra'));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.statisticsPerformanceRestaurantDetail);
      expect(routes.lastArguments, {'id': 9, 'name': 'Tacos Hydra'});
    });

    // M39
    testWidgets('the next ten, at the bottom', (tester) async {
      backend.replyInTurn('GET', restaurantsPath, [
        FakeReply(
          200,
          managerRestaurantsJson([managerRestaurantJson()], lastPage: 2),
        ),
        FakeReply(
          200,
          managerRestaurantsJson(
            [managerRestaurantJson(id: 9, name: 'Tacos Hydra')],
            currentPage: 2,
            lastPage: 2,
          ),
        ),
      ]);
      await pump(tester, const StatisticsOrdersRestaurantsScreen());

      await tester.tap(find.text(en.loadMore));
      await tester.pumpAndSettle();

      expect(backend.last('GET', restaurantsPath).query, {
        'page': 2,
        'per_page': 10,
      });
      expect(find.text('Tacos Hydra'), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsOrdersRestaurantsScreen(),
        themeMode: ThemeMode.dark,
      );

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsOrdersRestaurantsScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
