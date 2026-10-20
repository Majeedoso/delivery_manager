import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/features/coupons/data/models/coupon_model.dart';
import 'package:delivery_manager/features/coupons/data/models/delivery_zone_model.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/add_edit_coupon_screen.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump.dart';
import '../../../../helpers/readable.dart';
import '../../../../helpers/routes.dart';

/// A coupon's form, new or to change: its code and discount, for which
/// restaurant and zones, from when to when, how often and from what order.
void main() {
  late MockCouponsBloc coupons;
  late StreamController<CouponsState> states;
  late RouteLog routes;
  final fr = lookupAppLocalizations(const Locale('fr'));

  final rentree = CouponModel.fromJson(
    couponJson(
      zones: [
        {'id': 3, 'name': 'Bab Ezzouar'},
      ],
    ),
  );
  final babEzzouar = DeliveryZoneModel.fromJson(couponZoneJson());
  final hydra = DeliveryZoneModel.fromJson(
    couponZoneJson(id: 5, name: 'Hydra', description: null),
  );
  final ready = CouponsState(
    deliveryZones: [babEzzouar, hydra],
    restaurants: [
      managerRestaurantJson(),
      managerRestaurantJson(id: 9, name: 'Tacos Hydra'),
    ],
  );

  setUpAll(registerFallbacks);

  setUp(() {
    coupons = MockCouponsBloc();
    states = StreamController<CouponsState>.broadcast();
    addTearDown(states.close);
    routes = RouteLog();
  });

  /// Tests run on the fixed day: a new coupon starts today.
  void testForm(String description, Future<void> Function(WidgetTester) body) =>
      testWidgets(
        description,
        (tester) => withClock(Clock.fixed(testNow), () => body(tester)),
      );

  /// Opens the form as the coupons list does; its result is what it pops.
  Future<Future<bool?>> open(
    WidgetTester tester, {
    Coupon? coupon,
    String discountTarget = 'subtotal',
    CouponsState? state,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
  }) {
    whenListen(coupons, states.stream, initialState: state ?? ready);
    return pumpOpener<bool>(
      tester,
      (context) => Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<CouponsBloc>.value(
            value: coupons,
            child: AddEditCouponScreen(
              coupon: coupon,
              discountTarget: discountTarget,
            ),
          ),
        ),
      ),
      locale: locale,
      themeMode: themeMode,
      routes: routes,
    );
  }

  /// The events the form added, oldest first (each read once).
  List<CouponsEvent> added() =>
      verify(() => coupons.add(captureAny())).captured.cast<CouponsEvent>();

  Finder field(String hint) => find.widgetWithText(TextFormField, hint);

  Future<void> pick(WidgetTester tester, String shown, String choice) async {
    await scrollTo(tester, find.text(shown));
    await tester.tap(find.text(shown));
    await tester.pumpAndSettle();
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  /// The app bar's back arrow (pageBack looks for its English tooltip).
  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester, String button) async {
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
  }

  testForm('asks for the zones and the restaurants it offers', (tester) async {
    await open(tester);

    expect(added(), [
      const LoadDeliveryZonesEvent(),
      const LoadRestaurantsEvent(),
    ]);
  });

  group('a new coupon', () {
    testForm('is not sent without a code and a discount', (tester) async {
      await open(tester);
      added();

      await save(tester, 'Create');
      expect(find.text('Please enter a coupon code'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);

      await tester.enterText(field('e.g. SUMMER20'), 'AB');
      await tester.enterText(field('Value'), '150');
      await save(tester, 'Create');
      expect(find.text('Code must be at least 3 characters'), findsOneWidget);
      expect(find.text('Max 100%'), findsOneWidget);

      verifyNever(() => coupons.add(any()));
    });

    testForm('is sent with what was filled in', (tester) async {
      await open(tester);
      added();

      await tester.enterText(field('e.g. SUMMER20'), 'nuit20');
      await tester.enterText(field('Value'), '300');
      await pick(tester, 'Percentage', 'Fixed Amount');
      await pick(tester, 'Draft', 'Active');
      await pick(tester, 'All Restaurants (Global)', 'Tacos Hydra');
      await scrollTo(tester, find.text('Hydra'));
      await tester.tap(find.text('Hydra'));
      await tester.pump();
      await tester.enterText(field('Total uses'), '200');
      await tester.enterText(field('Per customer'), '1');
      await tester.enterText(field('Min order (DZD)'), '1000');
      await tester.enterText(field('Max discount (DZD)'), '300');
      await tester.enterText(
        field('Internal note about this coupon...'),
        '  Late evenings  ',
      );
      await save(tester, 'Create');

      expect(added(), [
        CreateCouponEvent(
          code: 'NUIT20',
          type: 'fixed_amount',
          value: 300,
          status: 'active',
          startDate: testNow,
          endDate: testNow.add(const Duration(days: 30)),
          restaurantId: 9,
          maxUsesTotal: 200,
          maxUsesPerCustomer: 1,
          minOrderValue: 1000,
          maxDiscountAmount: 300,
          description: 'Late evenings',
          deliveryZoneIds: const [5],
        ),
      ]);
    });

    testForm('of the page\'s kind: what the discount applies to', (
      tester,
    ) async {
      await open(tester, discountTarget: 'delivery_fee');
      expect(find.text('Delivery Fee'), findsOneWidget);
    });

    // M17: "Final Total (Global)" was English in every language
    testForm('a global coupon, in the manager\'s language', (tester) async {
      await open(
        tester,
        discountTarget: 'final_total',
        locale: const Locale('fr'),
      );

      expect(find.text(fr.finalTotalGlobal), findsOneWidget);
      expect(find.text('Final Total (Global)'), findsNothing);
    });
  });

  group('a coupon to change', () {
    testForm('shows what it is, and sends what was changed', (tester) async {
      await open(tester, coupon: rentree);
      added();

      expect(find.text('Edit Coupon'), findsOneWidget);
      expect(find.text('RENTREE10'), findsOneWidget);
      expect(find.text('Pizzeria Le Phare'), findsOneWidget);
      expect(find.text('1 zone selected'), findsOneWidget);

      await tester.enterText(field('Value'), '15');
      await pick(tester, 'Active', 'Disabled');
      await save(tester, 'Update');

      expect(added(), [
        UpdateCouponEvent(
          id: 31,
          code: 'RENTREE10',
          type: 'percentage',
          value: 15,
          status: 'disabled',
          startDate: DateTime.utc(2026, 9, 25),
          endDate: DateTime.utc(2026, 10, 31),
          restaurantId: 4,
          discountTarget: 'subtotal',
          maxUsesTotal: 100,
          maxUsesPerCustomer: 1,
          minOrderValue: 1500,
          maxDiscountAmount: 500,
          description: 'The first orders of the school year',
          deliveryZoneIds: const [3],
        ),
      ]);
    });

    // It started before today: the calendar refused to open on it
    testForm('one that has started keeps its start in the calendar', (
      tester,
    ) async {
      await open(tester, coupon: rentree);

      await tester.tap(find.text('Sep 25, 2026'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testForm('its zones: picked and unpicked, counted in the manager\'s '
        'language', (tester) async {
      await open(tester, coupon: rentree, locale: const Locale('fr'));

      expect(find.text('1 zone sélectionnée'), findsOneWidget);
      await scrollTo(tester, find.text('Hydra'));
      await tester.tap(find.text('Hydra'));
      await tester.pump();
      expect(find.text('2 zones sélectionnées'), findsOneWidget);
      expect(find.textContaining('selected'), findsNothing);
    });
  });

  group('saving', () {
    testForm('saved, the form closes and says so to the list', (tester) async {
      final result = await open(tester, coupon: rentree);

      states.add(
        ready.copyWith(operationStatus: CouponOperationStatus.success),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddEditCouponScreen), findsNothing);
      expect(await result, isTrue);
    });

    // After the save the list reloads, and its first state still carries
    // success: the closed form's listener must not run again and pop the list
    // too (it did, landing the manager two screens back on the coupons home).
    testForm('saving does not pop the list when it reloads', (tester) async {
      whenListen(coupons, states.stream, initialState: ready);
      // The real stack: the coupons home, its restaurant-coupons list, the form.
      await pumpPage(tester, const Scaffold(body: Text('home')), routes: routes);
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('list')),
        ),
      );
      await tester.pumpAndSettle();
      navigatorKey.currentState!.push(
        MaterialPageRoute<bool>(
          builder: (_) => BlocProvider<CouponsBloc>.value(
            value: coupons,
            child: const AddEditCouponScreen(discountTarget: 'subtotal'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AddEditCouponScreen), findsOneWidget);

      states.add(
        ready.copyWith(operationStatus: CouponOperationStatus.success),
      );
      states.add(
        ready.copyWith(
          operationStatus: CouponOperationStatus.success,
          isLoading: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddEditCouponScreen), findsNothing); // the form closed
      expect(find.text('list'), findsOneWidget); // the list stayed
    });

    testForm('while it is sent, the button waits', (tester) async {
      await open(tester, coupon: rentree);

      states.add(
        ready.copyWith(operationStatus: CouponOperationStatus.loading),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Update'), findsNothing);
      expect(
        tester
            .widget<TextButton>(
              find.ancestor(
                of: find.byType(CircularProgressIndicator),
                matching: find.byType(TextButton),
              ),
            )
            .onPressed,
        isNull,
      );
    });

    testForm('a refusal says the server\'s reason, and stays', (tester) async {
      await open(tester, coupon: rentree);

      states.add(
        ready.copyWith(
          operationStatus: CouponOperationStatus.failure,
          operationMessage: 'One or more selected zones are not available.',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('One or more selected zones are not available.'),
        findsOneWidget,
      );
      expect(find.byType(AddEditCouponScreen), findsOneWidget);
    });

    // M19: the network's failures were said in English
    testForm('a failed one is said in the manager\'s language', (tester) async {
      await open(tester, coupon: rentree, locale: const Locale('fr'));

      states.add(
        ready.copyWith(
          operationStatus: CouponOperationStatus.failure,
          operationMessage: 'Network connection error',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(fr.errorConnectionError), findsOneWidget);
    });
  });

  group('leaving with changes', () {
    testForm('asks first: staying keeps them, discarding leaves', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(field('e.g. SUMMER20'), 'NUIT20');
      await tester.pump();

      await back(tester);
      expect(find.text('Discard Changes?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEditCouponScreen), findsOneWidget);

      await back(tester);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEditCouponScreen), findsNothing);
    });

    testForm('in French, the two answers are told apart', (tester) async {
      await open(tester, locale: const Locale('fr'));
      await tester.enterText(field(fr.couponCodeHint), 'NUIT20');
      await tester.pump();

      await back(tester);

      final answers = tester
          .widgetList<TextButton>(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextButton),
            ),
          )
          .map((b) => ((b.child as Text).data))
          .toList();
      expect(answers, hasLength(2));
      expect(
        answers.toSet(),
        hasLength(2),
        reason: 'both read "Annuler": staying and losing the changes',
      );
    });

    testForm('without changes, it just leaves', (tester) async {
      await open(tester, coupon: rentree);

      await back(tester);

      expect(find.byType(AddEditCouponScreen), findsNothing);
    });
  });

  group('the zones and the restaurants', () {
    // M16: the zones page found no bloc (an error page); now it has its own,
    // and back from it the form asks for the zones again
    testForm('"Manage zones" opens the zones page; back, the zones are '
        'asked for again', (tester) async {
      await open(tester);
      added();

      await scrollTo(tester, find.byTooltip('Manage Zones'));
      await tester.tap(find.byTooltip('Manage Zones'));
      await tester.pumpAndSettle();
      expect(routes.names.last, AppRoutes.deliveryZones);

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(added(), [const LoadDeliveryZonesEvent()]);
    });

    testForm('no zone yet: a way to make them', (tester) async {
      await open(tester, state: CouponsState(restaurants: ready.restaurants));
      added();

      await scrollTo(tester, find.text('Manage Zones'));
      await tester.tap(find.text('Manage Zones'));
      await tester.pumpAndSettle();

      expect(routes.names.last, AppRoutes.deliveryZones);
    });

    testForm('could not be read: why, in the manager\'s language, and a '
        'retry for each', (tester) async {
      await open(
        tester,
        locale: const Locale('fr'),
        state: const CouponsState(
          zonesErrorMessage: 'Network connection error',
          restaurantsErrorMessage: 'Request timeout',
        ),
      );
      added();

      Finder retryBeside(String said) => find.descendant(
        of: find
            .ancestor(of: find.text(said), matching: find.byType(Row))
            .first,
        matching: find.text(fr.retry),
      );

      await scrollTo(tester, find.text(fr.errorNetworkTimeout));
      await tester.tap(retryBeside(fr.errorNetworkTimeout));
      await tester.pump();
      expect(added(), [const LoadRestaurantsEvent(refresh: true)]);

      await scrollTo(tester, find.text(fr.errorConnectionError));
      await tester.tap(retryBeside(fr.errorConnectionError));
      await tester.pump();
      expect(added(), [const LoadDeliveryZonesEvent()]);
      expect(find.text('Network connection error'), findsNothing);
    });

    testForm('no restaurant: the coupon will be for all', (tester) async {
      await open(tester, state: CouponsState(deliveryZones: [babEzzouar]));

      await scrollTo(
        tester,
        find.text('No restaurants available. This coupon will be global.'),
      );
    });

    testForm('a coupon\'s restaurant that is not in the list keeps its '
        'name', (tester) async {
      await open(
        tester,
        coupon: rentree,
        state: CouponsState(
          deliveryZones: [babEzzouar],
          restaurants: [managerRestaurantJson(id: 9, name: 'Tacos Hydra')],
        ),
      );

      await scrollTo(tester, find.text('Pizzeria Le Phare'));
    });
  });

  group('can be read', () {
    testForm('in dark mode', (tester) async {
      await open(tester, coupon: rentree, themeMode: ThemeMode.dark);
      expectReadable(tester);

      await scrollTo(tester, find.text('Hydra'));
      expectReadable(tester);
      await scrollTo(tester, find.text('The first orders of the school year'));
      expectReadable(tester);
    });

    testForm('in light mode', (tester) async {
      await open(tester, coupon: rentree);
      expectReadable(tester);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testForm('fits a phone in ${locale.languageCode}', (tester) async {
      await open(tester, coupon: rentree, locale: locale);
      expect(tester.takeException(), isNull);

      await scrollTo(tester, find.text('The first orders of the school year'));
      expect(tester.takeException(), isNull);
    });
  }
}
