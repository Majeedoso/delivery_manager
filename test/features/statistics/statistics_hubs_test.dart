import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_main_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump.dart';
import '../../helpers/readable.dart';
import '../../helpers/routes.dart';

/// The statistics' doors: four kinds (money, orders, ratings, performance),
/// and in each an overview, the restaurants and the drivers.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  Future<void> opensEach(
    WidgetTester tester,
    Widget page,
    List<(String, String)> doors,
  ) async {
    final routes = RouteLog();
    await pumpPage(tester, page, routes: routes);

    for (final (door, route) in doors) {
      await tester.tap(find.text(door));
      await tester.pumpAndSettle();

      expect(routes.last.name, route, reason: door);
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
    }
  }

  final hubs = <String, (Widget, List<(String, String)>)>{
    'statistics': (
      const StatisticsMainScreen(),
      [
        (en.statisticsMoney, AppRoutes.statisticsMoney),
        (en.statisticsOrders, AppRoutes.statisticsOrders),
        (en.statisticsRatings, AppRoutes.statisticsRatings),
        (en.statisticsPerformance, AppRoutes.statisticsPerformance),
      ],
    ),
    'money': (
      const StatisticsMoneyScreen(),
      [
        (en.overview, AppRoutes.statisticsMoneyOverview),
        (en.restaurantsTab, AppRoutes.statisticsMoneyRestaurants),
        (en.driversTab, AppRoutes.statisticsMoneyDrivers),
      ],
    ),
    'orders': (
      const StatisticsOrdersScreen(),
      [
        (en.overview, AppRoutes.statisticsOrdersOverview),
        (en.restaurantsTab, AppRoutes.statisticsOrdersRestaurants),
        (en.driversTab, AppRoutes.statisticsOrdersDrivers),
      ],
    ),
    'ratings': (
      const StatisticsRatingsScreen(),
      [
        (en.overview, AppRoutes.statisticsRatingsOverview),
        (en.restaurantsTab, AppRoutes.statisticsRatingsRestaurants),
        (en.driversTab, AppRoutes.statisticsRatingsDrivers),
      ],
    ),
    'performance': (
      const StatisticsPerformanceScreen(),
      [
        (en.overview, AppRoutes.statisticsPerformanceOverview),
        (en.restaurantsTab, AppRoutes.statisticsPerformanceRestaurants),
        (en.driversTab, AppRoutes.statisticsPerformanceDrivers),
      ],
    ),
  };

  for (final MapEntry(key: name, value: (page, doors)) in hubs.entries) {
    group(name, () {
      testWidgets('each door opens its page', (tester) async {
        await opensEach(tester, page, doors);
      });

      testWidgets('can be read in dark mode', (tester) async {
        await pumpPage(tester, page, themeMode: ThemeMode.dark);

        expectReadable(tester);
      });

      for (final locale in const [Locale('fr'), Locale('ar')]) {
        testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
          await pumpPage(tester, page, locale: locale);

          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
