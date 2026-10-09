import 'package:delivery_manager/core/utils/phone_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phoneText', () {
    test('a number keeps its plus at the start among right-to-left words', () {
      expect(phoneText('+213 555 12 34 56'), '\u2066+213 555 12 34 56\u2069');
    });

    test('an empty number stays empty', () {
      expect(phoneText(''), '');
    });
  });
}
