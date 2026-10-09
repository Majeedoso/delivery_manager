import 'package:clock/clock.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_driver_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_restaurant_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_restaurants_screen.dart';
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

/// The money pages: the money of the orders delivered in some days (what the
/// platform, the drivers and the restaurants earned of it), each driver's and
/// each restaurant's. They ask the server themselves (no bloc).
void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));
  const revenuePath = '/manager/analytics/revenue';
  const driversPath = '/manager/drivers';
  const restaurantsPath = '/manager/restaurants';
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend()
      ..reply('GET', revenuePath, body: revenueSummaryJson())
      ..reply(
        'GET',
        driversPath,
        body: managerDriversJson([managerDriverJson()]),
      )
      ..reply(
        'GET',
        restaurantsPath,
        body: managerRestaurantsJson([managerRestaurantJson()]),
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

  Future<void> choose(WidgetTester tester, String period) =>
      withClock(Clock.fixed(testNow), () async {
        await tester.tap(find.byType(DropdownButton2<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(period).last);
        await tester.pumpAndSettle();
      });

  group('the overview', () {
    testWidgets('this week by default: since Sunday', (tester) async {
      await pump(tester, const StatisticsMoneyOverviewScreen());

      expect(backend.last('GET', revenuePath).query, {
        'start_date': '2026-09-27',
        'end_date': '2026-09-30',
      });
    });

    testWidgets('the money of those days, and who earned it', (tester) async {
      await pump(tester, const StatisticsMoneyOverviewScreen());

      for (final amount in [
        '12,000.00',
        '10,500.00',
        '1,500.00',
        '1,350.00',
        '1,200.00',
        '9,450.00',
        '2,000.00',
      ]) {
        await tester.scrollUntilVisible(
          find.text('$amount ${en.currency}'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('$amount ${en.currency}'), findsOneWidget);
      }
    });

    testWidgets('another period asks for its days: today, or every day', (
      tester,
    ) async {
      await pump(tester, const StatisticsMoneyOverviewScreen());

      await choose(tester, en.today);
      expect(backend.last('GET', revenuePath).query, {
        'start_date': '2026-09-30',
        'end_date': '2026-09-30',
      });

      await choose(tester, en.thisMonth);
      expect(backend.last('GET', revenuePath).query, {
        'start_date': '2026-09-01',
        'end_date': '2026-09-30',
      });

      await choose(tester, en.all);
      expect(backend.last('GET', revenuePath).query, isEmpty);
    });

    testWidgets('not read: says so, and asks again', (tester) async {
      backend.fail('GET', revenuePath, DioExceptionType.connectionError);
      await pump(tester, const StatisticsMoneyOverviewScreen());

      expect(find.text(en.errorLoadingStatistics), findsOneWidget);

      backend.reply('GET', revenuePath, body: revenueSummaryJson());
      await tester.tap(find.text(en.tryAgain));
      await tester.pumpAndSettle();

      expect(find.text('12,000.00 ${en.currency}'), findsOneWidget);
      expect(backend.count('GET', revenuePath), 2);
    });

    testWidgets('a card explains what it counts', (tester) async {
      await pump(tester, const StatisticsMoneyOverviewScreen());

      await tester.tap(find.text(en.totalRevenue));
      await tester.pumpAndSettle();

      expect(find.text(en.totalRevenueDesc), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsMoneyOverviewScreen(),
        themeMode: ThemeMode.dark,
      );

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsMoneyOverviewScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  for (final (kind, page, path, detail, name, list) in [
    (
      'the drivers',
      const StatisticsMoneyDriversScreen(),
      driversPath,
      AppRoutes.statisticsMoneyDriverDetail,
      'Yacine Bouzid',
      (int page, int last, String name, int id) => managerDriversJson(
        [managerDriverJson(id: id, name: name)],
        currentPage: page,
        lastPage: last,
      ),
    ),
    (
      'the restaurants',
      const StatisticsMoneyRestaurantsScreen(),
      restaurantsPath,
      AppRoutes.statisticsMoneyRestaurantDetail,
      'Pizzeria Le Phare',
      (int page, int last, String name, int id) => managerRestaurantsJson(
        [managerRestaurantJson(id: id, name: name)],
        currentPage: page,
        lastPage: last,
      ),
    ),
  ]) {
    group(kind, () {
      testWidgets('the first ten, each by name', (tester) async {
        await pump(tester, page);

        expect(backend.last('GET', path).query, {'page': 1, 'per_page': 10});
        expect(find.text(name), findsOneWidget);
      });

      // M39: the next pages were read from `meta.pagination`, which the
      // server does not send: each list stopped at its first ten
      testWidgets('the next ten, at the bottom', (tester) async {
        backend.replyInTurn('GET', path, [
          FakeReply(200, list(1, 2, name, 4)),
          FakeReply(200, list(2, 2, 'Tacos Hydra', 9)),
        ]);
        await pump(tester, page);

        await tester.tap(find.text(en.loadMore));
        await tester.pumpAndSettle();

        expect(backend.last('GET', path).query, {'page': 2, 'per_page': 10});
        expect(find.text(name), findsOneWidget);
        expect(find.text('Tacos Hydra'), findsOneWidget);
        expect(find.text(en.loadMore), findsNothing);
      });

      testWidgets('each opens its money', (tester) async {
        final routes = RouteLog();
        await pump(tester, page, routes: routes);

        await tester.tap(find.text(name));
        await tester.pumpAndSettle();

        expect(routes.last.name, detail);
        expect(routes.lastArguments['name'], name);
      });

      testWidgets('not read: says so, and asks again', (tester) async {
        backend.fail('GET', path, DioExceptionType.receiveTimeout);
        await pump(tester, page);
        expect(find.text(en.errorLoadingStatistics), findsOneWidget);

        backend.reply('GET', path, body: list(1, 1, name, 4));
        await tester.tap(find.text(en.tryAgain));
        await tester.pumpAndSettle();

        expect(find.text(name), findsOneWidget);
      });

      testWidgets('none: says so', (tester) async {
        backend.reply(
          'GET',
          path,
          body: {...list(1, 1, name, 4), 'data': <Object>[]},
        );
        await pump(tester, page);

        expect(find.text(en.noStatisticsAvailable), findsOneWidget);
      });

      testWidgets('can be read in dark mode', (tester) async {
        await pump(tester, page, themeMode: ThemeMode.dark);

        expectReadable(tester);
      });

      for (final locale in const [Locale('fr'), Locale('ar')]) {
        testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
          await pump(tester, page, locale: locale);

          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  group('a driver\'s money', () {
    const page = StatisticsMoneyDriverDetailScreen(
      driverId: 25,
      driverName: 'Yacine Bouzid',
    );

    testWidgets('their delivered orders of this week', (tester) async {
      await pump(tester, page);

      expect(backend.last('GET', revenuePath).query, {
        'driver_id': 25,
        'start_date': '2026-09-27',
        'end_date': '2026-09-30',
      });
      expect(find.text('Yacine Bouzid'), findsOneWidget);
      expect(find.text('1,500.00 ${en.currency}'), findsOneWidget);
      expect(find.text('1,200.00 ${en.currency}'), findsOneWidget);
    });

    testWidgets('another period, the same driver', (tester) async {
      await pump(tester, page);

      await choose(tester, en.today);

      expect(backend.last('GET', revenuePath).query, {
        'driver_id': 25,
        'start_date': '2026-09-30',
        'end_date': '2026-09-30',
      });
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(tester, page, locale: locale);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('a restaurant\'s money', () {
    const page = StatisticsMoneyRestaurantDetailScreen(
      restaurantId: 4,
      restaurantName: 'Pizzeria Le Phare',
    );

    testWidgets('its delivered orders of this week', (tester) async {
      await pump(tester, page);

      expect(backend.last('GET', revenuePath).query, {
        'restaurant_id': 4,
        'start_date': '2026-09-27',
        'end_date': '2026-09-30',
      });
      expect(find.text('10,500.00 ${en.currency}'), findsOneWidget);
      expect(find.text('9,450.00 ${en.currency}'), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(tester, page, themeMode: ThemeMode.dark);

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(tester, page, locale: locale);

        expect(tester.takeException(), isNull);
        expect(
          find.text('9,450.00 ${lookupAppLocalizations(locale).currency}'),
          findsOneWidget,
        );
      });
    }
  });

  testWidgets('in French, as the server writes the amounts', (tester) async {
    await pump(
      tester,
      const StatisticsMoneyOverviewScreen(),
      locale: const Locale('fr'),
    );

    expect(find.text(fr.totalRevenue), findsOneWidget);
    expect(find.text('12,000.00 ${fr.currency}'), findsOneWidget);
  });
}
