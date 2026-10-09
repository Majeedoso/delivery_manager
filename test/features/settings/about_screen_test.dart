import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/app_config/domain/entities/contact_info.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_contact_info_usecase.dart';
import 'package:delivery_manager/features/settings/presentation/screens/about_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/locator.dart';
import '../../helpers/platform.dart';
import '../../helpers/pump.dart';
import 'package:delivery_manager/core/utils/phone_text.dart';

class _MockContactInfo extends Mock implements GetContactInfoUseCase {}

/// "About": the app's version and the company's contact details from the
/// server, each one a tap away (mail, call, website).
void main() {
  late _MockContactInfo contactInfo;
  final en = lookupAppLocalizations(const Locale('en'));

  setUpAll(() => registerFallbackValue(const NoParameters()));

  setUp(() {
    contactInfo = _MockContactInfo();
    registerUseCase<GetContactInfoUseCase>(contactInfo);
    when(() => contactInfo(any())).thenAnswer(
      (_) async => const Right(
        ContactInfo(
          email: 'contact@example.dz',
          phone: '+213 21 00 00 00',
          website: 'example.dz',
        ),
      ),
    );
    PackageInfo.setMockInitialValues(
      appName: 'Delivery',
      packageName: 'website.sofistem.delivery_manager',
      version: '1.2.0',
      buildNumber: '7',
      buildSignature: '',
    );
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) => pumpPage(tester, const AboutScreen(), locale: locale);

  Future<void> tapContact(WidgetTester tester, String value) async {
    await scrollTo(tester, find.text(value));
    await tester.tap(find.text(value));
    await tester.pumpAndSettle();
  }

  testWidgets('the app\'s real version', (tester) async {
    await pump(tester);

    expect(find.text('v1.2.0'), findsOneWidget);
    expect(find.text('v1.0.0'), findsNothing);
  });

  testWidgets('says what the app does, as it does it', (tester) async {
    await pump(tester);
    await scrollTo(tester, find.text('Coupons'));

    // The manager's four: the accounts, the numbers, the platform's
    // settings, the coupons
    expect(find.text('User Management'), findsOneWidget);
    expect(find.text('Analytics & Reports'), findsOneWidget);
    expect(find.text('System Settings'), findsOneWidget);
    expect(find.text('Coupons'), findsOneWidget);
    expect(
      find.text(
        'Create coupons, set their limits and the zones where they apply',
      ),
      findsOneWidget,
    );
  });

  testWidgets('promises nothing the app cannot do', (tester) async {
    // It said "Zone Management: define and activate delivery zones to
    // control where orders can be placed". The app's zones are the
    // coupons' zones: no page of it edits where the platform delivers
    for (final locale in const [Locale('en'), Locale('fr'), Locale('ar')]) {
      final l10n = lookupAppLocalizations(locale);
      for (final text in [
        l10n.aboutDescription,
        l10n.googleSignIn,
        l10n.googleSignInDescription,
      ]) {
        expect(
          text.toLowerCase(),
          isNot(
            anyOf(
              contains('delivery zone'),
              contains('zones de livraison'),
              contains('مناطق التوصيل'),
            ),
          ),
          reason: '${locale.languageCode}: $text',
        );
      }
    }
  });

  testWidgets('the contact details from the server', (tester) async {
    await pump(tester);
    await scrollTo(tester, find.text(en.copyright('${clock.now().year}')));

    expect(find.text('contact@example.dz'), findsOneWidget);
    // Kept left to right: an Arabic page showed the "+" at the end (E8)
    expect(find.text(phoneText('+213 21 00 00 00')), findsOneWidget);
    expect(find.text('example.dz'), findsOneWidget);
  });

  group('a tap on a contact', () {
    testWidgets('writes an email', (tester) async {
      await pump(tester);

      await tapContact(tester, 'contact@example.dz');

      expect(urlLauncher.launched, [
        'mailto:contact@example.dz',
      ], reason: 'the contact details could not be tapped');
    });

    testWidgets('calls the number', (tester) async {
      await pump(tester);

      await tapContact(tester, phoneText('+213 21 00 00 00'));

      expect(urlLauncher.launched, ['tel:+21321000000']);
    });

    testWidgets('opens the website', (tester) async {
      await pump(tester);

      await tapContact(tester, 'example.dz');

      expect(urlLauncher.launched, ['https://example.dz']);
    });

    testWidgets('a website that isn\'t one opens nothing', (tester) async {
      when(() => contactInfo(any())).thenAnswer(
        (_) async => const Right(ContactInfo(website: 'javascript:alert(1)')),
      );
      await pump(tester);

      await tapContact(tester, 'javascript:alert(1)');

      expect(urlLauncher.launched, isEmpty);
    });
  });

  testWidgets('missing details are left out', (tester) async {
    when(() => contactInfo(any())).thenAnswer(
      (_) async => const Right(ContactInfo(email: 'contact@example.dz')),
    );
    await pump(tester);
    await scrollTo(tester, find.text(en.copyright('${clock.now().year}')));

    expect(find.text(en.phone), findsNothing);
    expect(find.text(en.website), findsNothing);
  });

  testWidgets('offline: the page without contacts', (tester) async {
    when(
      () => contactInfo(any()),
    ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
    await pump(tester);
    await scrollTo(tester, find.text(en.copyright('${clock.now().year}')));

    expect(find.text(en.email), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);
      await scrollTo(
        tester,
        find.text(
          lookupAppLocalizations(locale).copyright('${clock.now().year}'),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
