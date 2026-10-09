import 'package:delivery_manager/core/utils/amounts.dart';
import 'package:flutter_test/flutter_test.dart';

/// The server sends amounts as numbers on some screens and written for display
/// on others ("2,455.00", PHP's number_format). The driver collects that cash,
/// so every form must read as the same number of dinars.
void main() {
  group('parseAmount', () {
    test('reads numbers and numeric strings', () {
      expect(parseAmount(2455), 2455);
      expect(parseAmount(2455.0), 2455);
      expect(parseAmount('2455.00'), 2455);
      expect(parseAmount('55'), 55);
    });

    test('reads amounts written with thousands separators', () {
      expect(
        parseAmount('2,455.00'),
        2455,
        reason: 'read as a plain number, an order of 2,455 DA showed 0 DA',
      );
      expect(parseAmount('12,345,678.00'), 12345678);
      expect(parseAmount('1 200'), 1200);
      expect(parseAmount('1\u202f200'), 1200);
    });

    test('rounds to whole dinars', () {
      expect(parseAmount('99.50'), 100);
      expect(parseAmount(99.49), 99);
    });

    test('reads anything else as 0', () {
      expect(parseAmount(null), 0);
      expect(parseAmount(''), 0);
      expect(parseAmount('n/a'), 0);
      expect(parseAmount(true), 0);
    });
  });

  group('parseTypedAmount', () {
    test('reads a comma as the decimal point', () {
      expect(
        parseTypedAmount('12,5'),
        12.5,
        reason: 'a French keyboard writes the comma: it was refused',
      );
      expect(parseTypedAmount('12.5'), 12.5);
      expect(parseTypedAmount('5000'), 5000);
      expect(parseTypedAmount('12٫5'), 12.5);
    });

    test('ignores spaces, around and inside', () {
      expect(parseTypedAmount(' 5000 '), 5000);
      expect(parseTypedAmount('1 500'), 1500);
      expect(parseTypedAmount('1\u00a0500,50'), 1500.5);
    });

    test('reads Arabic digits', () {
      expect(parseTypedAmount('١٢٥٠'), 1250);
      expect(parseTypedAmount('۱۲٫۵'), 12.5);
    });

    test('says when it is not a number', () {
      expect(parseTypedAmount(null), isNull);
      expect(parseTypedAmount(''), isNull);
      expect(parseTypedAmount('abc'), isNull);
      expect(
        parseTypedAmount('1,234.50'),
        isNull,
        reason: 'two decimal marks: the person is asked, not guessed for',
      );
    });
  });
}
