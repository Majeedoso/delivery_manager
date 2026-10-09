import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/features/delivery_areas/data/models/delivery_area_model.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_bloc.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_event.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_state.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/screens/delivery_areas_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/readable.dart';

/// "Delivery Zones": where customers can order, each zone on or off, made,
/// changed and deleted here. The app had no page for them (decision 4 of
/// manager_suite_report.md): a manager could not open a zone or close one.
void main() {
  late MockDeliveryAreasBloc zones;
  late StreamController<DeliveryAreasState> states;
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));

  DeliveryArea zone(int id, String name, {bool on = true, String? about}) =>
      DeliveryAreaModel.fromJson(
        deliveryAreaJson(id: id, name: name, isActive: on, description: about),
      );

  final centre = zone(1, 'Alger Centre', about: 'The Grande Poste');
  final hydra = zone(2, 'Hydra', on: false);
  final loaded = DeliveryAreasState(
    status: DeliveryAreasStatus.loaded,
    areas: [centre, hydra],
  );

  setUpAll(registerFallbacks);

  setUp(() {
    zones = MockDeliveryAreasBloc();
    states = StreamController<DeliveryAreasState>.broadcast();
  });

  tearDown(() => states.close());

  Future<void> pump(
    WidgetTester tester, {
    DeliveryAreasState? state,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
  }) {
    whenListen(zones, states.stream, initialState: state ?? loaded);
    return pumpPage(
      tester,
      const DeliveryAreasScreen(),
      locale: locale,
      themeMode: themeMode,
      blocs: [BlocProvider<DeliveryAreasBloc>.value(value: zones)],
    );
  }

  /// The events the page added, oldest first (each read once).
  List<DeliveryAreasEvent> added() =>
      verify(() => zones.add(captureAny())).captured.cast<DeliveryAreasEvent>();

  /// Fills the form's fields, in order: name, description, latitude,
  /// longitude, radius.
  Future<void> fill(WidgetTester tester, List<String> texts) async {
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    for (var i = 0; i < texts.length; i++) {
      await tester.enterText(fields.at(i), texts[i]);
    }
    await tester.pump();
  }

  testWidgets('each zone: its name, whether customers can order there, its '
      'centre and radius', (tester) async {
    await pump(tester);

    expect(find.text('Delivery Zones'), findsOneWidget);
    expect(find.text(en.deliveryAreasHelp), findsOneWidget);
    expect(find.text('Alger Centre'), findsOneWidget);
    expect(find.text('The Grande Poste'), findsOneWidget);
    expect(find.text(en.deliveryAreaOn), findsOneWidget);
    expect(find.text(en.deliveryAreaOff), findsOneWidget);
    expect(find.text('36.7538, 3.0588 · 5.0 km'), findsNWidgets(2));
  });

  testWidgets('a zone is switched off or on with its switch', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(added(), [const SwitchDeliveryAreaEvent(1)]);
  });

  testWidgets('while it is sent, its switch waits', (tester) async {
    await pump(tester, state: loaded.copyWith(busyId: 1));

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.first.onChanged, isNull);
    expect(switches.last.onChanged, isNotNull);
  });

  group('the form', () {
    testWidgets('a new zone, typed the French way or in Arabic digits', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text(en.addDeliveryArea), findsOneWidget);
      await fill(tester, ['Bab Ezzouar', '', '36,7167', '3,1833', '٢٫٥']);
      await tester.tap(find.text(en.create));
      await tester.pumpAndSettle();

      expect(added(), [
        const SaveDeliveryAreaEvent(
          DeliveryAreaDraft(
            name: 'Bab Ezzouar',
            latitude: 36.7167,
            longitude: 3.1833,
            radiusKm: 2.5,
          ),
        ),
      ]);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('a zone changed keeps its id and whether it is on', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text('Hydra'));
      await tester.pumpAndSettle();
      expect(find.text(en.editDeliveryArea), findsOneWidget);
      await fill(tester, ['Hydra et Ben Aknoun', 'Up the hill']);
      await tester.tap(find.text(en.update));
      await tester.pumpAndSettle();

      expect(added(), [
        const SaveDeliveryAreaEvent(
          DeliveryAreaDraft(
            id: 2,
            name: 'Hydra et Ben Aknoun',
            description: 'Up the hill',
            latitude: 36.7538,
            longitude: 3.0588,
            radiusKm: 5,
            isActive: false,
          ),
        ),
      ]);
    });

    for (final (what, texts, said) in [
      ('without a name', ['', '', '36.7', '3.1', '2'], 'zoneNameIsRequired'),
      (
        'with no place',
        ['Bab Ezzouar', '', '136.7', '3.1', '2'],
        'coordinatesInvalid',
      ),
      (
        'with a radius the server refuses',
        ['Bab Ezzouar', '', '36.7', '3.1', '0'],
        'radiusOutOfRange',
      ),
    ]) {
      testWidgets('$what: says why, and sends nothing', (tester) async {
        await pump(tester);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await fill(tester, texts);
        await tester.tap(find.text(en.create));
        await tester.pumpAndSettle();

        final sentence = switch (said) {
          'zoneNameIsRequired' => en.zoneNameIsRequired,
          'coordinatesInvalid' => en.coordinatesInvalid,
          _ => en.radiusOutOfRange,
        };
        expect(find.text(sentence), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget);
        verifyNever(() => zones.add(any()));
      });
    }
  });

  testWidgets('a zone is deleted after a question naming it', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.delete));
    await tester.pumpAndSettle();
    expect(
      find.text(en.deleteDeliveryAreaConfirmation('Hydra')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(en.delete),
      ),
    );
    await tester.pumpAndSettle();

    expect(added(), [const DeleteDeliveryAreaEvent(2)]);
  });

  testWidgets('a failed action is said in the manager\'s language, once', (
    tester,
  ) async {
    await pump(tester, locale: const Locale('fr'));

    states.add(loaded.copyWith(actionFailure: 'Network connection error'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(fr.errorConnectionError), findsOneWidget);
    expect(added(), [const ClearDeliveryAreaFailureEvent()]);
    expect(find.text('Alger Centre'), findsOneWidget);
  });

  testWidgets('no zone yet: no customer can order, and one can be made', (
    tester,
  ) async {
    await pump(
      tester,
      state: const DeliveryAreasState(status: DeliveryAreasStatus.loaded),
    );

    expect(find.text(en.noDeliveryAreasYet), findsOneWidget);
    await tester.tap(find.text(en.addDeliveryArea));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('zones that cannot be read: why, and a retry', (tester) async {
    await pump(
      tester,
      locale: const Locale('fr'),
      state: const DeliveryAreasState(
        status: DeliveryAreasStatus.error,
        errorMessage: 'Request timeout',
      ),
    );

    expect(find.text(fr.errorNetworkTimeout), findsOneWidget);
    await tester.tap(find.text(fr.retry));
    await tester.pump();

    expect(added(), [const LoadDeliveryAreasEvent()]);
  });

  group('can be read', () {
    testWidgets('in dark mode, and its form', (tester) async {
      await pump(tester, themeMode: ThemeMode.dark);
      expectReadable(tester);

      await tester.tap(find.text('Hydra'));
      await tester.pumpAndSettle();
      expectReadable(tester);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
