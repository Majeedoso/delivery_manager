import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/routes/route_generator.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/coupons/data/models/delivery_zone_model.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/delivery_zones_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/readable.dart';

/// "Coupon Zones": the areas a coupon can be limited to (a name, and a
/// centre with a radius), created, changed and deleted here.
void main() {
  late MockCouponsBloc coupons;
  late StreamController<CouponsState> states;
  final fr = lookupAppLocalizations(const Locale('fr'));

  final babEzzouar = DeliveryZoneModel.fromJson(couponZoneJson());
  final hydra = DeliveryZoneModel.fromJson(
    couponZoneJson(
      id: 5,
      name: 'Hydra',
      description: null,
      latitude: null,
      longitude: null,
      radiusKm: null,
    ),
  );
  final both = CouponsState(deliveryZones: [babEzzouar, hydra]);

  setUpAll(registerFallbacks);

  setUp(() {
    coupons = MockCouponsBloc();
    states = StreamController<CouponsState>.broadcast();
    addTearDown(states.close);
  });

  Future<void> pump(
    WidgetTester tester, {
    CouponsState? state,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    bool settle = true,
  }) {
    whenListen(coupons, states.stream, initialState: state ?? both);
    return pumpPage(
      tester,
      const DeliveryZonesScreen(),
      locale: locale,
      themeMode: themeMode,
      settle: settle,
      blocs: [BlocProvider<CouponsBloc>.value(value: coupons)],
    );
  }

  List<CouponsEvent> added() =>
      verify(() => coupons.add(captureAny())).captured.cast<CouponsEvent>();

  Finder field(String label) => find.widgetWithText(TextField, label);

  Future<void> menu(WidgetTester tester, String zone, String choice) async {
    await tester.tap(
      find.descendant(
        of: find.ancestor(of: find.text(zone), matching: find.byType(Card)),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  testWidgets('asks for the zones on arrival', (tester) async {
    await pump(tester);

    expect(added(), [const LoadDeliveryZonesEvent()]);
  });

  testWidgets('each zone: its name, what it is, where and how wide', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Bab Ezzouar'), findsOneWidget);
    expect(find.text('Around the university'), findsOneWidget);
    expect(find.text('36.7167, 3.1833'), findsOneWidget);
    expect(find.text('2.5 km'), findsOneWidget);
    expect(find.text('Hydra'), findsOneWidget);
  });

  group('a new zone', () {
    testWidgets('needs a name', (tester) async {
      await pump(tester);
      added();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.text('Zone name is required'), findsOneWidget);
      verifyNever(() => coupons.add(any()));
    });

    testWidgets('is sent with its centre and its radius', (tester) async {
      await pump(tester);
      added();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(field('Zone Name *'), ' Kouba ');
      await tester.enterText(field('Description'), 'Near the market');
      await tester.enterText(field('Latitude'), '36.72');
      await tester.enterText(field('Longitude'), '3.08');
      await tester.enterText(field('Radius (km)'), '1.5');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(added(), [
        const CreateDeliveryZoneEvent(
          name: 'Kouba',
          description: 'Near the market',
          latitude: 36.72,
          longitude: 3.08,
          radiusKm: 1.5,
        ),
      ]);
    });

    testWidgets('no zone yet: a way to make the first', (tester) async {
      await pump(tester, state: const CouponsState());

      expect(find.text('No coupon zones yet'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Zone'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  testWidgets('a zone changed keeps what was not touched', (tester) async {
    await pump(tester);
    added();

    await menu(tester, 'Bab Ezzouar', 'Edit');
    expect(find.text('Edit Zone'), findsOneWidget);
    await tester.enterText(field('Radius (km)'), '3');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Update'));
    await tester.pumpAndSettle();

    expect(added(), [
      const UpdateDeliveryZoneEvent(
        id: 3,
        name: 'Bab Ezzouar',
        description: 'Around the university',
        latitude: 36.7167,
        longitude: 3.1833,
        radiusKm: 3,
      ),
    ]);
  });

  testWidgets('a zone is deleted once confirmed', (tester) async {
    await pump(tester);
    added();

    await menu(tester, 'Hydra', 'Delete');
    expect(
      find.text('Are you sure you want to delete "Hydra"?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => coupons.add(any()));

    await menu(tester, 'Hydra', 'Delete');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(added(), [const DeleteDeliveryZoneEvent(id: 5)]);
  });

  group('what saving did', () {
    // M17: "Zone created successfully!" was English; the zone shows in the
    // list, as the other apps' saved results do
    testWidgets('saved: the list shows it, nothing is said', (tester) async {
      await pump(tester, state: CouponsState(deliveryZones: [babEzzouar]));

      states.add(
        CouponsState(
          deliveryZones: [babEzzouar, hydra],
          zoneOperationStatus: ZoneOperationStatus.success,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hydra'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('refused: the server\'s reason', (tester) async {
      await pump(tester);

      states.add(
        both.copyWith(
          zoneOperationStatus: ZoneOperationStatus.failure,
          zoneOperationMessage:
              'The latitude field must be between -90 and 90.',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('The latitude field must be between -90 and 90.'),
        findsOneWidget,
      );
    });

    // M19: the network's failures were said in English
    testWidgets('failed: said in the manager\'s language', (tester) async {
      await pump(tester, locale: const Locale('fr'));

      states.add(
        both.copyWith(
          zoneOperationStatus: ZoneOperationStatus.failure,
          zoneOperationMessage: 'Network connection error',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(fr.errorConnectionError), findsOneWidget);
    });
  });

  group('the list', () {
    testWidgets('loading: a spinner', (tester) async {
      await pump(
        tester,
        state: const CouponsState(isLoadingZones: true),
        settle: false,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('could not be read: why, in the manager\'s language, and a '
        'retry', (tester) async {
      await pump(
        tester,
        locale: const Locale('fr'),
        state: const CouponsState(zonesErrorMessage: 'Request timeout'),
      );
      added();

      expect(find.text(fr.errorNetworkTimeout), findsOneWidget);
      await tester.tap(find.text(fr.retry));
      await tester.pump();
      expect(added(), [const LoadDeliveryZonesEvent()]);
    });
  });

  // M16: the route handed the page the coupon form's bloc, which is not
  // above the navigator: the page found none, and showed an error
  testWidgets('opens from the route table on its own', (tester) async {
    final bloc = MockCouponsBloc();
    whenListen(bloc, const Stream<CouponsState>.empty(), initialState: both);
    sl.registerFactory<CouponsBloc>(() => bloc);
    final routes = RouteGenerator.generateRoutes();

    await pumpPage(
      tester,
      Builder(builder: (context) => routes[AppRoutes.deliveryZones]!(context)),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Bab Ezzouar'), findsOneWidget);
    verify(() => bloc.add(const LoadDeliveryZonesEvent())).called(1);
  });

  group('can be read', () {
    testWidgets('in dark mode, and its dialog', (tester) async {
      await pump(tester, themeMode: ThemeMode.dark);
      expectReadable(tester);

      await menu(tester, 'Bab Ezzouar', 'Edit');
      expectReadable(tester);
    });

    testWidgets('in light mode', (tester) async {
      await pump(tester);
      expectReadable(tester);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}, its dialog too', (
      tester,
    ) async {
      await pump(tester, locale: locale);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
