import 'dart:io';

import 'package:delivery_manager/core/utils/week.dart';
import 'package:delivery_manager/core/utils/week_material_localizations.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The week begins on Sunday in every language (the owner's rule), and so
/// does a calendar's: Flutter begins it on the language's own first day,
/// Saturday in Arabic, Monday in French. Everything else Flutter says and
/// writes in a language stays as it is.
void main() {
  const delegate = WeekMaterialLocalizations.delegate;
  const languages = ['ar', 'en', 'fr'];

  Future<MaterialLocalizations> ours(String language) =>
      delegate.load(Locale(language));
  Future<MaterialLocalizations> flutters(String language) =>
      GlobalMaterialLocalizations.delegate.load(Locale(language));

  test('the week begins on Sunday', () {
    expect(firstDayOfWeek, DateTime.sunday);
  });

  test('a calendar\'s week begins on Sunday in each language', () async {
    expect(
      [
        for (final language in languages)
          (await flutters(language)).firstDayOfWeekIndex,
      ],
      [6, 0, 1],
      reason:
          'left to Flutter: Saturday in Arabic, Sunday in English, '
          'Monday in French',
    );
    expect(
      [
        for (final language in languages)
          (await ours(language)).firstDayOfWeekIndex,
      ],
      [0, 0, 0],
    );
  });

  for (final language in languages) {
    test('$language: the words and the formats are Flutter\'s own', () async {
      final mine = await ours(language);
      final stock = await flutters(language);
      final day = DateTime(2026, 10, 4, 9, 5);
      const time = TimeOfDay(hour: 21, minute: 5);

      List<Object> said(MaterialLocalizations l10n) => [
        l10n.okButtonLabel,
        l10n.cancelButtonLabel,
        l10n.datePickerHelpText,
        l10n.narrowWeekdays,
        l10n.formatYear(day),
        l10n.formatCompactDate(day),
        l10n.formatShortDate(day),
        l10n.formatMediumDate(day),
        l10n.formatFullDate(day),
        l10n.formatMonthYear(day),
        l10n.formatShortMonthDay(day),
        l10n.formatDecimal(1234567),
        l10n.formatHour(time),
        l10n.formatMinute(time),
        l10n.formatTimeOfDay(time),
        l10n.timeOfDayFormat(),
        l10n.scriptCategory,
      ];

      expect(said(mine), said(stock));
      expect(mine.runtimeType, isNot(stock.runtimeType));
    });
  }

  test('a language the app does not speak is left to Flutter', () {
    expect(
      [
        for (final language in [...languages, 'de'])
          delegate.isSupported(Locale(language)),
      ],
      [true, true, true, false],
    );
  });

  test('the app lists it before Flutter\'s own, which it would hide', () {
    // This app has no test of its shell yet: read from main.dart
    final main = File('lib/main.dart').readAsStringSync();
    final ours = main.indexOf('WeekMaterialLocalizations.delegate,');
    final flutters = main.indexOf('GlobalMaterialLocalizations.delegate,');

    expect(ours, isNot(-1));
    expect(ours, lessThan(flutters));
    expect(
      main.substring(0, ours),
      contains('localizationsDelegates: const ['),
    );
  });

  group('a date picker', () {
    for (final language in languages) {
      testWidgets('in $language shows Sunday to Saturday on one row', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            // As main.dart
            localizationsDelegates: const [
              WeekMaterialLocalizations.delegate,
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDatePicker(
                    context: context,
                    initialDate: DateTime(2026, 10, 7),
                    firstDate: DateTime(2026),
                    lastDate: DateTime(2026, 12, 31),
                  ),
                  child: const Text('pick'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('pick'));
        await tester.pumpAndSettle();

        final calendar = find.byType(CalendarDatePicker);
        final l10n = MaterialLocalizations.of(tester.element(calendar));
        Offset at(int day) => tester.getCenter(
          find.descendant(
            of: calendar,
            matching: find.text(l10n.formatDecimal(day)),
          ),
        );

        // October 2026: Sunday the 4th to Saturday the 10th
        expect(at(10).dy, at(4).dy);
        expect(
          at(3).dy,
          lessThan(at(4).dy),
          reason:
              'Saturday the 3rd ends the row above (it began the row '
              'in Arabic)',
        );
        expect(
          at(11).dy,
          greaterThan(at(10).dy),
          reason:
              'Sunday the 11th begins the row below (it ended the row '
              'in French)',
        );
        // Sunday is where a row begins: on the right in Arabic
        final rightToLeft = language == 'ar';
        expect(
          at(4).dx,
          rightToLeft ? greaterThan(at(5).dx) : lessThan(at(5).dx),
        );
      });
    }
  });
}
