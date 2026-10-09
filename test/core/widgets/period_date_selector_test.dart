import 'package:delivery_manager/core/widgets/period_date_selector.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

/// The period filter of the bank and the statistics. A period that has a name
/// is the calendar one (the owner's rule): this week since Sunday, this month
/// since the 1st, this year since 1 January. The last 7 days have no name:
/// whoever wants them picks the days. The filter said "Week" for the last
/// seven days, and "day" for today.
void main() {
  Future<void> pumpSelector(
    WidgetTester tester, {
    String period = 'all',
    Locale locale = const Locale('en'),
    void Function(String)? onPicked,
  }) async {
    tester.view.physicalSize = const Size(360, 780) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, screenType) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PeriodDateSelector(
                selectedPeriod: period,
                dateFrom: null,
                dateTo: null,
                onPeriodChanged: onPicked ?? (_) {},
                onDateFromSelected: (_) async {},
                onDateToSelected: (_) async {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButton2<String>));
    await tester.pumpAndSettle();
  }

  for (final (language, names, not) in [
    (
      'en',
      ['Today', 'This Week', 'This Month', 'This Year'],
      ['day', 'Week', 'Month', 'Year', 'Last 7 days', 'Last 30 days'],
    ),
    (
      'fr',
      ['Aujourd\'hui', 'Cette semaine', 'Ce mois', 'Cette année'],
      ['Semaine', 'Mois', 'Année', '7 derniers jours', '30 derniers jours'],
    ),
    (
      'ar',
      ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذه السنة'],
      ['أسبوع', 'شهر', 'سنة', 'آخر 7 أيام', 'آخر 30 يومًا'],
    ),
  ]) {
    testWidgets('in $language: today, then this week, month and year', (
      tester,
    ) async {
      // No period chosen: each name shows once, in the list
      await pumpSelector(tester, locale: Locale(language));
      await open(tester);

      for (final name in names) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      for (final name in not) {
        expect(find.text(name), findsNothing, reason: name);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a name picked is still the period the pages know', (
    tester,
  ) async {
    final picked = <String>[];
    await pumpSelector(tester, onPicked: picked.add);

    for (final (name, period) in [
      ('This Week', 'week'),
      ('This Month', 'month'),
      ('This Year', 'year'),
      ('Today', 'day'),
    ]) {
      await open(tester);
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
      expect(picked.last, period, reason: name);
    }
  });

  testWidgets('the one chosen is shown by the same name', (tester) async {
    await pumpSelector(tester, period: 'week');
    expect(find.text('This Week'), findsOneWidget);

    await pumpSelector(tester, period: 'year', locale: const Locale('fr'));
    expect(find.text('Cette année'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('the name of a period, wherever a page writes it', () {
    final en = lookupAppLocalizations(const Locale('en'));

    expect(
      [
        for (final period in [
          'all',
          'day',
          'week',
          'month',
          'year',
          'dateRange',
        ])
          periodLabel(en, period),
      ],
      ['All', 'Today', 'This Week', 'This Month', 'This Year', 'Date Range'],
    );
  });
}
