import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/localization/presentation/screens/first_run_language_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/routes.dart';

/// Choosing the app's language on the very first start: its own words follow
/// the language picked, before any is saved.
void main() {
  late MockLocalizationBloc localization;
  late StreamController<LocalizationState> states;
  late RouteLog routes;

  final arabic = Language.supportedLanguages[0];
  final french = Language.supportedLanguages[2];

  setUpAll(registerFallbacks);

  setUp(() {
    localization = MockLocalizationBloc();
    states = StreamController<LocalizationState>.broadcast();
    routes = RouteLog();
    whenListen(
      localization,
      states.stream,
      initialState: LocalizationState(currentLanguage: french),
    );
  });

  tearDown(() => states.close());

  Future<void> pump(WidgetTester tester, Widget screen) => pumpPage(
    tester,
    screen,
    routes: routes,
    blocs: [BlocProvider<LocalizationBloc>.value(value: localization)],
  );

  group('the first start', () {
    testWidgets('speaks the language shown as chosen', (tester) async {
      await pump(tester, const FirstRunLanguageScreen());

      expect(find.text('Choisissez votre langue'), findsOneWidget);
      expect(find.text('Confirmer'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(
        find.text('English'),
        findsWidgets,
        reason: 'native name and name',
      );
      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('its words follow a new pick', (tester) async {
      await pump(tester, const FirstRunLanguageScreen());

      await tester.tap(find.text('العربية'));
      verify(() => localization.add(ChangeLanguageEvent(arabic))).called(1);

      states.add(LocalizationState(currentLanguage: arabic));
      await tester.pumpAndSettle();
      expect(find.text('اختر لغتك'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);
    });

    testWidgets('confirm keeps the language shown and starts the app', (
      tester,
    ) async {
      await pump(tester, const FirstRunLanguageScreen());

      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      verify(() => localization.add(ChangeLanguageEvent(french))).called(1);
      expect(routes.last.name, AppRoutes.splash);
      expect(find.byType(FirstRunLanguageScreen), findsNothing);
    });

    testWidgets('the settings are at hand', (tester) async {
      await pump(tester, const FirstRunLanguageScreen());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(routes.last.name, AppRoutes.settings);
    });

    testWidgets('fits a phone', (tester) async {
      whenListen(
        localization,
        states.stream,
        initialState: LocalizationState(currentLanguage: arabic),
      );
      await pump(tester, const FirstRunLanguageScreen());

      expect(tester.takeException(), isNull);
    });
  });
}
