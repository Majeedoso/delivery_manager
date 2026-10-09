import 'package:clock/clock.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_driver_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_restaurant_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_restaurants_screen.dart';
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

/// The performance pages: how the restaurants decide and how fast, how the
/// deliveries go, for all or for one. They send the days their filter names
/// (this week since Sunday, this month, this year): sent by name, the server
/// counted its own, and "Today" was refused.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));
  const restaurantsStatsPath = '/manager/restaurants/statistics/overview';
  const deliveriesPath = '/manager/deliveries/analytics';
  const driversPath = '/manager/drivers';
  const restaurantsPath = '/manager/restaurants';
  const pizzeriaStatsPath = '/manager/restaurants/4/statistics';
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend()
      ..reply('GET', restaurantsStatsPath, body: restaurantStatisticsJson())
      ..reply('GET', pizzeriaStatsPath, body: restaurantStatisticsJson())
      ..reply('GET', deliveriesPath, body: deliveryAnalyticsJson())
      // The deliveries' own rating, which nothing fills, reads 0
      ..reply(
        'GET',
        driversPath,
        body: managerDriversJson([managerDriverJson(averageRating: 0)]),
      )
      ..reply(
        'GET',
        restaurantsPath,
        body: managerRestaurantsJson([managerRestaurantJson(isOpen: true)]),
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

  const thisWeek = {
    'period': 'custom',
    'start_date': '2026-09-27',
    'end_date': '2026-09-30',
  };

  group('the overview', () {
    testWidgets('this week, the same days for the restaurants and for the '
        'deliveries', (tester) async {
      await pump(tester, const StatisticsPerformanceOverviewScreen());

      expect(find.text(en.thisWeek), findsOneWidget);
      expect(backend.last('GET', restaurantsStatsPath).query, thisWeek);
      expect(backend.last('GET', deliveriesPath).query, thisWeek);
    });

    testWidgets('each period sends its own days; "All" none', (tester) async {
      await pump(tester, const StatisticsPerformanceOverviewScreen());

      for (final (name, first) in [
        (en.today, '2026-09-30'),
        (en.thisMonth, '2026-09-01'),
        (en.thisYear, '2026-01-01'),
      ]) {
        await choose(tester, name);

        for (final path in [restaurantsStatsPath, deliveriesPath]) {
          expect(backend.last('GET', path).query, {
            'period': 'custom',
            'start_date': first,
            'end_date': '2026-09-30',
          }, reason: '$name, $path');
        }
      }

      await choose(tester, en.all);
      for (final path in [restaurantsStatsPath, deliveriesPath]) {
        expect(backend.last('GET', path).query, {'period': 'all'});
      }
    });

    testWidgets('the restaurants\' decisions, and the deliveries', (
      tester,
    ) async {
      await pump(tester, const StatisticsPerformanceOverviewScreen());

      for (final value in [
        '9',
        '1.5 ${en.minutesAbbr}',
        '14.2 ${en.minutesAbbr}',
        '87.5%',
        '20',
        '90.0%',
        '28 ${en.minutesAbbr}',
        '85.0%',
        '48 ${en.minutesAbbr}',
        '10.0%',
      ]) {
        await tester.scrollUntilVisible(
          find.text(value).first,
          200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text(value), findsWidgets, reason: value);
      }
    });

    // M40: a time not known read "N/A", and seconds "s", in English
    testWidgets('a time not known yet, and seconds, in the manager\'s '
        'language', (tester) async {
      backend.reply(
        'GET',
        restaurantsStatsPath,
        body: restaurantStatisticsJson(
          responseSpeed: 0.75,
          preparationSpeed: null,
        ),
      );
      await pump(
        tester,
        const StatisticsPerformanceOverviewScreen(),
        locale: const Locale('fr'),
      );

      expect(find.text('45 ${fr.seconds}'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('N/A'), findsNothing);
      expect(find.text('45 s'), findsNothing);
    });

    testWidgets('not read: says so, and asks again', (tester) async {
      backend.fail('GET', deliveriesPath, DioExceptionType.connectionError);
      await pump(tester, const StatisticsPerformanceOverviewScreen());
      expect(find.text(en.errorLoadingStatistics), findsOneWidget);

      backend.reply('GET', deliveriesPath, body: deliveryAnalyticsJson());
      await tester.tap(find.text(en.tryAgain));
      await tester.pumpAndSettle();

      expect(find.text(en.errorLoadingStatistics), findsNothing);
      expect(backend.count('GET', deliveriesPath), 2);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsPerformanceOverviewScreen(),
        themeMode: ThemeMode.dark,
      );

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsPerformanceOverviewScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the drivers', () {
    // M42: every driver read 0.0 stars: the deliveries' own rating, which
    // nothing fills, instead of the customers' ratings
    testWidgets('each with the customers\' stars, opening its performance', (
      tester,
    ) async {
      final routes = RouteLog();
      await pump(
        tester,
        const StatisticsPerformanceDriversScreen(),
        routes: routes,
      );

      expect(find.text('4.7'), findsOneWidget);
      expect(find.text('0.0'), findsNothing);

      await tester.tap(find.text('Yacine Bouzid'));
      await tester.pumpAndSettle();
      expect(routes.last.name, AppRoutes.statisticsPerformanceDriverDetail);
      expect(routes.lastArguments, {'id': 25, 'name': 'Yacine Bouzid'});
    });

    // M39
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
      await pump(tester, const StatisticsPerformanceDriversScreen());

      await tester.tap(find.text(en.loadMore));
      await tester.pumpAndSettle();

      expect(find.text('Sofiane Amrani'), findsOneWidget);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsPerformanceDriversScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the restaurants', () {
    testWidgets('each with its stars, opening its performance', (tester) async {
      final routes = RouteLog();
      await pump(
        tester,
        const StatisticsPerformanceRestaurantsScreen(),
        routes: routes,
      );

      expect(find.text('4.5'), findsOneWidget);
      await tester.tap(find.text('Pizzeria Le Phare'));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.statisticsPerformanceRestaurantDetail);
      expect(routes.lastArguments, {'id': 4, 'name': 'Pizzeria Le Phare'});
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
      await pump(tester, const StatisticsPerformanceRestaurantsScreen());

      await tester.tap(find.text(en.loadMore));
      await tester.pumpAndSettle();

      expect(find.text('Tacos Hydra'), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsPerformanceRestaurantsScreen(),
        themeMode: ThemeMode.dark,
      );

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsPerformanceRestaurantsScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('one driver', () {
    const page = StatisticsPerformanceDriverDetailScreen(
      driverId: 25,
      driverName: 'Yacine Bouzid',
    );

    testWidgets('their deliveries of this week', (tester) async {
      await pump(tester, page);

      expect(backend.last('GET', deliveriesPath).query, {
        'driver_id': 25,
        'start_date': '2026-09-27',
        'end_date': '2026-09-30',
      });
      expect(find.text('Yacine Bouzid'), findsOneWidget);
      expect(find.text('90.0%'), findsOneWidget);
    });

    testWidgets('today: the same driver', (tester) async {
      await pump(tester, page);

      await choose(tester, en.today);

      expect(backend.last('GET', deliveriesPath).query, {
        'driver_id': 25,
        'start_date': '2026-09-30',
        'end_date': '2026-09-30',
      });
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

  group('one restaurant', () {
    const page = StatisticsPerformanceRestaurantDetailScreen(
      restaurantId: 4,
      restaurantName: 'Pizzeria Le Phare',
    );

    testWidgets('this week; each period its own days; "All" none', (
      tester,
    ) async {
      await pump(tester, page);
      expect(backend.last('GET', pizzeriaStatsPath).query, thisWeek);

      for (final (name, first) in [
        (en.today, '2026-09-30'),
        (en.thisMonth, '2026-09-01'),
        (en.thisYear, '2026-01-01'),
      ]) {
        await choose(tester, name);

        expect(backend.last('GET', pizzeriaStatsPath).query, {
          'period': 'custom',
          'start_date': first,
          'end_date': '2026-09-30',
        }, reason: name);
      }

      await choose(tester, en.all);
      expect(backend.last('GET', pizzeriaStatsPath).query, {'period': 'all'});
    });

    testWidgets('its decisions, and how fast', (tester) async {
      await pump(tester, page);

      expect(find.text('Pizzeria Le Phare'), findsOneWidget);
      for (final value in ['9', '87.5%', '1.5 ${en.minutesAbbr}']) {
        await tester.scrollUntilVisible(
          find.text(value).first,
          200,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text(value), findsWidgets, reason: value);
      }
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
