import 'dart:io';

import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app's name, the same in every language: short under its icon, or the
/// launcher cuts it, and whole in the app
/// (decision 20 of the restaurant report: the phone showed "delivery_manager").
void main() {
  const names = {'en': 'LihLih Manager', 'fr': 'LihLih Manager', 'ar': 'LihLih Manager'};

  String installedName(String folder) {
    final xml = File(
      'android/app/src/main/res/$folder/strings.xml',
    ).readAsStringSync();
    return RegExp(
      r'<string name="app_name">([^<]*)</string>',
    ).firstMatch(xml)!.group(1)!;
  }

  test('the phone shows the name of the string resources', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:label="@string/app_name"'));
    expect(manifest, isNot(contains('android:label="delivery_')));
  });

  test('under the icon, the short name in every language', () {
    expect(installedName('values'), 'Manager');
    expect(installedName('values-fr'), 'Manager');
    expect(installedName('values-ar'), 'Manager');
  });

  test('inside, the app calls itself by its whole name', () {
    for (final MapEntry(key: language, value: name) in names.entries) {
      expect(lookupAppLocalizations(Locale(language)).appName, name);
    }
  });

  test('the copyright line says the year it is given, in each language', () {
    String line(String language) =>
        lookupAppLocalizations(Locale(language)).copyright('2027');

    expect(line('en'), '© 2027 LihLih Manager. All rights reserved.');
    expect(line('fr'), '© 2027 LihLih Manager. Tous droits réservés.');
    expect(line('ar'), '© 2027 LihLih Manager. جميع الحقوق محفوظة.');
  });
}
