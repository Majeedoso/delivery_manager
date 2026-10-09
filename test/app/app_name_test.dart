import 'dart:io';

import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app's name, under its icon and in the app, in the phone's language
/// (decision 20 of the restaurant report: the phone showed "delivery_manager").
void main() {
  const names = {'en': 'Manager App', 'fr': 'Appli Gestionnaire', 'ar': 'تطبيق المدير'};

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

  test('in the phone\'s language', () {
    expect(installedName('values'), names['en']);
    expect(installedName('values-fr'), names['fr']);
    expect(installedName('values-ar'), names['ar']);
  });

  test('the app calls itself by the same name', () {
    for (final MapEntry(key: language, value: name) in names.entries) {
      expect(lookupAppLocalizations(Locale(language)).appName, name);
    }
  });

  test('the copyright line says the year it is given, in each language', () {
    String line(String language) =>
        lookupAppLocalizations(Locale(language)).copyright('2027');

    expect(line('en'), '© 2027 Manager App. All rights reserved.');
    expect(line('fr'), '© 2027 Appli Gestionnaire. Tous droits réservés.');
    expect(line('ar'), '© 2027 تطبيق المدير. جميع الحقوق محفوظة.');
  });
}
