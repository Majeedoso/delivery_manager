import 'package:delivery_manager/core/utils/week.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Flutter's own texts and formats in the app's three languages, with one
/// change: a calendar's week begins on [firstDayOfWeek] in each of them.
///
/// Left to Flutter, a date picker begins its week on the first day of the
/// language: Saturday in Arabic, Monday in French, Sunday in English.
///
/// It goes before `GlobalMaterialLocalizations.delegate` in the app's list:
/// the first delegate that knows the language is the one used.
class WeekMaterialLocalizations
    extends LocalizationsDelegate<MaterialLocalizations> {
  const WeekMaterialLocalizations();

  static const delegate = WeekMaterialLocalizations();

  @override
  bool isSupported(Locale locale) =>
      const ['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // Flutter's delegate first: it loads the date words of every language,
    // which the formats below read
    GlobalMaterialLocalizations.delegate.load(locale);

    final language = locale.languageCode;
    final build = switch (language) {
      'ar' => _Arabic.new,
      'fr' => _French.new,
      _ => _English.new,
    };
    // The formats Flutter's delegate gives its own (material_localizations.dart
    // of flutter_localizations)
    return SynchronousFuture<MaterialLocalizations>(
      build(
        fullYearFormat: intl.DateFormat.y(language),
        compactDateFormat: intl.DateFormat.yMd(language),
        shortDateFormat: intl.DateFormat.yMMMd(language),
        mediumDateFormat: intl.DateFormat.MMMEd(language),
        longDateFormat: intl.DateFormat.yMMMMEEEEd(language),
        yearMonthFormat: intl.DateFormat.yMMMM(language),
        shortMonthDayFormat: intl.DateFormat.MMMd(language),
        decimalFormat: intl.NumberFormat.decimalPattern(language),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', language),
      ),
    );
  }

  @override
  bool shouldReload(WeekMaterialLocalizations old) => false;
}

/// 0 is Sunday for Flutter, 7 for Dart.
mixin _WeekFromItsFirstDay on GlobalMaterialLocalizations {
  @override
  int get firstDayOfWeekIndex => firstDayOfWeek % DateTime.daysPerWeek;
}

class _Arabic = MaterialLocalizationAr with _WeekFromItsFirstDay;
class _English = MaterialLocalizationEn with _WeekFromItsFirstDay;
class _French = MaterialLocalizationFr with _WeekFromItsFirstDay;
