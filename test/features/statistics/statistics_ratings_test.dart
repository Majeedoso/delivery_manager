import 'package:clock/clock.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_restaurants_screen.dart';
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

/// The ratings pages: the ratings given in some days, and each driver's and
/// each restaurant's, with the reviews their customers wrote.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  const statisticsPath = '/manager/ratings/statistics';
  const driversPath = '/manager/drivers';
  const restaurantsPath = '/manager/restaurants';
  const yacineReviewsPath = '/manager/drivers/25/ratings';
  const pizzeriaReviewsPath = '/manager/restaurants/4/ratings';
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend()
      ..reply('GET', statisticsPath, body: ratingStatisticsJson())
      ..reply(
        'GET',
        driversPath,
        body: managerDriversJson([managerDriverJson()]),
      )
      ..reply(
        'GET',
        restaurantsPath,
        body: managerRestaurantsJson([managerRestaurantJson()]),
      )
      ..reply('GET', yacineReviewsPath, body: reviewsPageJson([reviewJson()]))
      ..reply(
        'GET',
        pizzeriaReviewsPath,
        body: reviewsPageJson([reviewJson()], ofDriver: false),
      );
    registerService<Dio>(testDio(backend));
  });

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
  }) => withClock(
    Clock.fixed(testNow),
    () => pumpPage(tester, page, locale: locale, themeMode: themeMode),
  );

  /// The day a review given at [utc] (the server's clock) is shown on: the
  /// phone's, so that the test passes in any time zone.
  String shownDay(DateTime utc) {
    final local = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  group('the overview', () {
    testWidgets('this week by default: since Sunday', (tester) async {
      await pump(tester, const StatisticsRatingsOverviewScreen());

      expect(backend.last('GET', statisticsPath).query, {
        'start_date': '2026-09-27',
        'end_date': '2026-09-30',
      });
    });

    testWidgets('how many, and how good', (tester) async {
      backend.reply(
        'GET',
        statisticsPath,
        body: ratingStatisticsJson(averageRating: 4.4),
      );
      await pump(tester, const StatisticsRatingsOverviewScreen());

      expect(find.text('4.4 ${en.outOf5}'), findsOneWidget);
      expect(find.text('20 ${en.totalRatings}'), findsOneWidget);
    });

    testWidgets('another period asks for its days', (tester) async {
      await pump(tester, const StatisticsRatingsOverviewScreen());

      await withClock(Clock.fixed(testNow), () async {
        await tester.tap(find.byType(DropdownButton2<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(en.thisYear).last);
        await tester.pumpAndSettle();
      });

      expect(backend.last('GET', statisticsPath).query, {
        'start_date': '2026-01-01',
        'end_date': '2026-09-30',
      });
    });

    testWidgets('not read: says so, and asks again', (tester) async {
      backend.fail('GET', statisticsPath, DioExceptionType.connectionError);
      await pump(tester, const StatisticsRatingsOverviewScreen());
      expect(find.text(en.errorLoadingStatistics), findsOneWidget);

      backend.reply('GET', statisticsPath, body: ratingStatisticsJson());
      await tester.tap(find.text(en.tryAgain));
      await tester.pumpAndSettle();

      expect(find.text('20 ${en.totalRatings}'), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsRatingsOverviewScreen(),
        themeMode: ThemeMode.dark,
      );

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsRatingsOverviewScreen(),
          locale: locale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the drivers', () {
    Future<void> openYacine(WidgetTester tester) async {
      await tester.tap(find.text('Yacine Bouzid'));
      await tester.pumpAndSettle();
    }

    testWidgets('each with the customers\' stars and how many', (tester) async {
      await pump(tester, const StatisticsRatingsDriversScreen());

      expect(backend.last('GET', driversPath).query, {'per_page': 100});
      expect(find.text('4.7'), findsOneWidget);
      expect(find.text('18 ${en.reviews}'), findsOneWidget);
    });

    // M41: the day was the server's (UTC): a review given at 00:30 read the
    // day before
    testWidgets('a driver\'s reviews: who wrote what, on the phone\'s day', (
      tester,
    ) async {
      await pump(tester, const StatisticsRatingsDriversScreen());
      await openYacine(tester);

      expect(backend.last('GET', yacineReviewsPath).query, {
        'page': 1,
        'per_page': 20,
      });
      expect(find.text('Amina Kaci'), findsOneWidget);
      expect(find.text('Pizzeria Le Phare'), findsOneWidget);
      // What the customer said of the driver, before what they said of all
      expect(find.text('Très poli'), findsOneWidget);
      expect(
        find.text(' · ${shownDay(DateTime.utc(2026, 9, 29, 23, 30))}'),
        findsOneWidget,
      );
    });

    testWidgets('a driver\'s next reviews, at the bottom', (tester) async {
      backend.replyInTurn('GET', yacineReviewsPath, [
        FakeReply(200, reviewsPageJson([reviewJson()], lastPage: 2)),
        FakeReply(
          200,
          reviewsPageJson(
            [reviewJson(id: 91, driverComment: 'Un peu en retard')],
            currentPage: 2,
            lastPage: 2,
          ),
        ),
      ]);
      await pump(tester, const StatisticsRatingsDriversScreen());
      await openYacine(tester);

      await tester.scrollUntilVisible(
        find.text(en.loadMore),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text(en.loadMore));
      await tester.pumpAndSettle();

      expect(backend.last('GET', yacineReviewsPath).query, {
        'page': 2,
        'per_page': 20,
      });
      expect(find.text('Un peu en retard'), findsOneWidget);
    });

    testWidgets('none yet: says so', (tester) async {
      backend.reply('GET', yacineReviewsPath, body: reviewsPageJson([]));
      await pump(tester, const StatisticsRatingsDriversScreen());
      await openYacine(tester);

      expect(find.text(en.noRatingsYet), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsRatingsDriversScreen(),
        themeMode: ThemeMode.dark,
      );
      expectReadable(tester);

      await openYacine(tester);
      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsRatingsDriversScreen(),
          locale: locale,
        );
        expect(tester.takeException(), isNull);

        await openYacine(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the restaurants', () {
    Future<void> openPizzeria(WidgetTester tester) async {
      await tester.tap(find.text('Pizzeria Le Phare'));
      await tester.pumpAndSettle();
    }

    // M43 (the server): the stars came from an old reviews table nothing
    // fills; they are the customers' ratings
    testWidgets('each with its stars and how many reviews', (tester) async {
      await pump(tester, const StatisticsRatingsRestaurantsScreen());

      expect(backend.last('GET', restaurantsPath).query, {'per_page': 100});
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('20 ${en.reviews}'), findsOneWidget);
    });

    // M41
    testWidgets('a restaurant\'s reviews, on the phone\'s day', (tester) async {
      await pump(tester, const StatisticsRatingsRestaurantsScreen());
      await openPizzeria(tester);

      expect(backend.last('GET', pizzeriaReviewsPath).query, {
        'page': 1,
        'per_page': 20,
      });
      expect(find.text('Amina Kaci'), findsOneWidget);
      expect(find.text('Rapide et chaud'), findsOneWidget);
      expect(
        find.textContaining(shownDay(DateTime.utc(2026, 9, 29, 23, 30))),
        findsOneWidget,
      );
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(
        tester,
        const StatisticsRatingsRestaurantsScreen(),
        themeMode: ThemeMode.dark,
      );
      expectReadable(tester);

      await openPizzeria(tester);
      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(
          tester,
          const StatisticsRatingsRestaurantsScreen(),
          locale: locale,
        );
        expect(tester.takeException(), isNull);

        await openPizzeria(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
