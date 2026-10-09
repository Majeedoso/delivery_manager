import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app speaks English, French and Arabic. A key missing from one file
/// falls back silently, and a key written twice keeps only its last value, so
/// editing the first copy changes nothing (150 keys were written two to five
/// times). These checks keep the three files in step with the English
/// template, and catch a file saved in the wrong encoding: half the French and
/// Arabic texts were shown as "TÃ©lÃ©phone" and "Ø³Ø§Ø¦Ù‚".
void main() {
  const languages = ['en', 'fr', 'ar'];

  String read(String language) =>
      File('lib/l10n/app_$language.arb').readAsStringSync();

  Map<String, dynamic> messages(String language) {
    final arb = jsonDecode(read(language)) as Map<String, dynamic>;
    return {
      for (final entry in arb.entries)
        if (!entry.key.startsWith('@')) entry.key: entry.value,
    };
  }

  Set<String> placeholders(Object? message) =>
      // A name, then "," (plural/select) or "}": not a plural's "{1 item}"
      RegExp(
        r'\{([A-Za-z_]\w*)\s*[,}]',
      ).allMatches('$message').map((m) => m[1]!).toSet();

  final template = messages('en');

  for (final language in languages) {
    group('app_$language.arb', () {
      test('declares its locale', () {
        final arb = jsonDecode(read(language)) as Map<String, dynamic>;
        expect(arb['@@locale'], language);
      });

      test('writes every key once', () {
        // Top-level keys sit at two spaces of indentation.
        final keys = RegExp(r'^  "([^"]+)":', multiLine: true)
            .allMatches(read(language).replaceAll('\r\n', '\n'))
            .map((m) => m[1]!)
            .toList();
        final repeated = {
          for (final key in keys)
            if (keys.where((k) => k == key).length > 1) key,
        };

        expect(repeated, isEmpty, reason: 'only the last copy would count');
      });

      test('keeps its letters: nothing double-encoded or lost', () {
        final damaged = [
          for (final entry in messages(language).entries)
            if (_doubleEncoded('${entry.value}') ||
                _lostLetters.hasMatch('${entry.value}'))
              '${entry.key}: ${entry.value}',
        ];

        expect(
          damaged,
          isEmpty,
          reason:
              'UTF-8 read as Windows-1252 and saved again shows "Ã©" for "é"; '
              'a letter saved as "?" is gone',
        );
      });

      if (language == 'en') return;

      test('has every key of the English template, and no others', () {
        final translated = messages(language);

        expect(
          template.keys.toSet().difference(translated.keys.toSet()),
          isEmpty,
          reason: 'missing keys',
        );
        expect(
          translated.keys.toSet().difference(template.keys.toSet()),
          isEmpty,
          reason: 'keys the template does not have',
        );
      });

      test('uses the same placeholders as English', () {
        final translated = messages(language);
        final mismatched = [
          for (final key in template.keys)
            if (translated.containsKey(key) &&
                !const SetEquality().equals(
                  placeholders(template[key]),
                  placeholders(translated[key]),
                ))
              key,
        ];

        expect(mismatched, isEmpty);
      });

      test('is translated: no English text left', () {
        final translated = messages(language);
        // Letters only: "Notify you..." is the English of "• Notify you..."
        // (three notification lines were left so, their bullet removed)
        String letters(Object? text) =>
            '$text'.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
        final english = [
          for (final key in template.keys)
            if (translated.containsKey(key) &&
                letters(translated[key]) == letters(template[key]) &&
                RegExp('[A-Za-z]{3,}').hasMatch('${template[key]}') &&
                !(language == 'fr' && _sameInFrench.contains(key)))
              key,
        ];

        expect(
          english,
          isEmpty,
          reason:
              'these show in English (28 did in French and in Arabic: the '
              'platform settings, the notification dialogs, the account '
              'status page)',
        );
      });
      if (language == 'fr') {
        test('calls a driver "livreur", never "chauffeur"', () {
          final otherWords = [
            for (final entry in messages(language).entries)
              if (_notLivreur.hasMatch('${entry.value}'))
                '${entry.key}: ${entry.value}',
          ];

          expect(
            otherWords,
            isEmpty,
            reason: 'the owner chose "livreur" (2026-10-03)',
          );
        });
        // "Discard" read "Annuler", as "Cancel": in the save-or-discard
        // dialog the button that throws the changes away read as staying
        test('tells throwing the changes away from cancelling', () {
          expect(
            messages(language)['discard'],
            isNot(messages(language)['cancel']),
          );
        });
      }
    });
  }
}

/// Texts French writes like English (words, units, store names).
const _sameInFrench = {
  'appName',
  'notifications',
  'version',
  'total',
  'deliveryNotes',
  'archive',
  'minute',
  'minutes',
  'restaurant',
  'restaurants',
  'description',
  'notes',
  'appStore',
  'playStore',
  'latitude',
  'longitude',
  'latitudeShort',
  'longitudeShort',
  'menu',
  'image',
  'transactions',
  'transactionType',
  'date',
  'ratingsDate',
  'ratingsService',
  'ratingsTags',
  'performance',
  'distance',
  'distanceKm',
  'distanceMeters',
  'minutesShort',
  'approxDzdValue',
  'pointsToDzd',
  'priceDa',
  'couponWithCode',
  'pointsAmount',
  'customerNameHint',
  'restaurantCredits',
  // The manager's pages: the same words in French
  'coupons',
  'googleSignIn',
  'email',
  'dzd',
  'currency',
  'type',
  'min1',
  'max100Percent',
  'zone',
  'zones',
  'restaurantsShort',
  'restaurantsTab',
  'statisticsPerformance',
  'minutesAbbr',
  // Written the French way ("Note :")
  'paymentNote',
};

/// "???" (Arabic saved by a tool that couldn't write it) or a "?" inside a
/// word ("s?lection").
final _lostLetters = RegExp(r'\?{3}|[A-Za-zÀ-ÿ]\?[A-Za-zÀ-ÿ]');

/// Whether [text] is UTF-8 that was read as Windows-1252 and saved again:
/// written back as Windows-1252 bytes, it reads as different, valid UTF-8.
bool _doubleEncoded(String text) {
  if (text.runes.every((rune) => rune < 0x80)) return false;
  final bytes = <int>[];
  for (final rune in text.runes) {
    final byte = rune < 0x80 || (rune >= 0xA0 && rune <= 0xFF)
        ? rune
        : _windows1252[rune] ?? (_undefinedIn1252.contains(rune) ? rune : null);
    if (byte == null) return false; // not a character Windows-1252 can write
    bytes.add(byte);
  }
  try {
    return utf8.decode(bytes) != text;
  } on FormatException {
    return false;
  }
}

/// The characters Windows-1252 puts in 0x80-0x9F, and their bytes.
const _windows1252 = {
  0x20AC: 0x80, 0x201A: 0x82, 0x0192: 0x83, 0x201E: 0x84, 0x2026: 0x85, //
  0x2020: 0x86, 0x2021: 0x87, 0x02C6: 0x88, 0x2030: 0x89, 0x0160: 0x8A, //
  0x2039: 0x8B, 0x0152: 0x8C, 0x017D: 0x8E, 0x2018: 0x91, 0x2019: 0x92, //
  0x201C: 0x93, 0x201D: 0x94, 0x2022: 0x95, 0x2013: 0x96, 0x2014: 0x97, //
  0x02DC: 0x98, 0x2122: 0x99, 0x0161: 0x9A, 0x203A: 0x9B, 0x0153: 0x9C, //
  0x017E: 0x9E, 0x0178: 0x9F,
};

/// Bytes Windows-1252 leaves undefined: a reader passes them through as is.
const _undefinedIn1252 = {0x81, 0x8D, 0x8F, 0x90, 0x9D};

/// Set equality without pulling in package:collection.
class SetEquality {
  const SetEquality();

  bool equals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

/// The words French used for a driver before "livreur" was chosen.
final _notLivreur = RegExp('chauffeu|conducteu', caseSensitive: false);
