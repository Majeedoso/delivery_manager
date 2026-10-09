import 'package:delivery_manager/core/utils/password_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app checks a new password with the server's own rule
/// (`Password::min(8)->mixedCase()->numbers()->symbols()`), so a manager is
/// never told a password is wrong when the server would take it.
void main() {
  group('complexity', () {
    test('any punctuation, symbol or space counts, not only @\$!%*?&', () {
      for (final password in [
        'Secret#2026',
        'Yasmine.2026',
        'Yasmine_2026',
        'Yasmine-2026',
        'Secret@2026',
        'Secret 2026',
      ]) {
        expect(PasswordRules.isComplex(password), isTrue, reason: password);
      }
    });

    test('each missing kind of character is refused', () {
      expect(
        PasswordRules.isComplex('secret#2026'),
        isFalse,
        reason: 'no upper case',
      );
      expect(
        PasswordRules.isComplex('SECRET#2026'),
        isFalse,
        reason: 'no lower case',
      );
      expect(
        PasswordRules.isComplex('Secret#abcd'),
        isFalse,
        reason: 'no number',
      );
      expect(
        PasswordRules.isComplex('Secret2026'),
        isFalse,
        reason: 'no symbol',
      );
    });

    test('letters and digits beyond ASCII count, as on the server', () {
      expect(PasswordRules.isComplex('Élève#2026'), isTrue);
      expect(
        PasswordRules.isComplex('Secret#٢٠٢٦'),
        isTrue,
        reason: 'Arabic-Indic digits are numbers',
      );
    });
  });

  group('length', () {
    test('8 characters are enough, 7 are not', () {
      expect(PasswordRules.isLongEnough('Ab#1abcd'), isTrue);
      expect(PasswordRules.isLongEnough('Ab#1abc'), isFalse);
    });

    test('an emoji is one character, as the server counts it', () {
      expect('Ab#1ab😀'.length, 8, reason: 'two UTF-16 units');
      expect(PasswordRules.isLongEnough('Ab#1ab😀'), isFalse);
    });
  });
}
