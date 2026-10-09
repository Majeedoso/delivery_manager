import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/routes/route_generator.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/coupons/data/models/coupon_model.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/add_edit_coupon_screen.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/coupons_list_screen.dart';
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

/// A list of one kind of coupon (restaurant, delivery or global): each card
/// says the discount, for whom, when and how often; a filter by status, the
/// next page at the bottom, a new coupon and each coupon's form.
void main() {
  late MockCouponsBloc coupons;
  late StreamController<CouponsState> states;
  final fr = lookupAppLocalizations(const Locale('fr'));

  Coupon coupon(Map<String, dynamic> json) => CouponModel.fromJson(json);

  final rentree = coupon(couponJson());
  final nuit = coupon(
    couponJson(
      id: 32,
      code: 'NUIT20',
      type: 'fixed_amount',
      value: 300,
      status: 'draft',
      maxUsesTotal: null,
      minOrderValue: null,
      restaurant: null,
      issuerType: 'restaurant',
      startDate: '2026-10-01',
      endDate: '2026-10-15',
    ),
  );
  final ended = coupon(
    couponJson(
      id: 33,
      code: 'ETE2026',
      status: 'disabled',
      startDate: '2026-07-01',
      endDate: '2026-09-29',
    ),
  );
  final lastDay = coupon(
    couponJson(id: 34, code: 'DERNIER', endDate: '2026-09-30'),
  );

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
    String discountTarget = 'subtotal',
    bool settle = true,
  }) {
    whenListen(
      coupons,
      states.stream,
      initialState: state ?? CouponsState(coupons: [rentree, nuit], total: 2),
    );
    return withClock(
      Clock.fixed(testNow),
      () => pumpPage(
        tester,
        CouponsListScreen(
          title: 'Restaurant Coupons',
          discountTarget: discountTarget,
        ),
        locale: locale,
        themeMode: themeMode,
        settle: settle,
        blocs: [BlocProvider<CouponsBloc>.value(value: coupons)],
      ),
    );
  }

  /// The events the page added, oldest first (each read once).
  List<CouponsEvent> added() =>
      verify(() => coupons.add(captureAny())).captured.cast<CouponsEvent>();

  testWidgets('asks for its kind of coupon on arrival', (tester) async {
    await pump(tester, discountTarget: 'delivery_fee');

    expect(added(), [
      const LoadCouponsEvent(refresh: true, discountTarget: 'delivery_fee'),
    ]);
  });

  testWidgets('each coupon: the code, the discount, for whom, when, how '
      'often', (tester) async {
    await pump(tester);

    expect(find.text('RENTREE10'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.textContaining('Pizzeria Le Phare'), findsOneWidget);
    expect(find.text('Sep 25, 2026 - Oct 31, 2026'), findsOneWidget);
    expect(find.text('12/100'), findsOneWidget);
    expect(find.text('1500 DZD'), findsOneWidget);

    expect(find.text('NUIT20'), findsOneWidget);
    expect(find.text('300 DZD'), findsOneWidget);
    expect(find.text('Global (all restaurants)'), findsOneWidget);
    expect(find.text('12 (unlimited)'), findsOneWidget);
  });

  // M17: the status, who issued it, "(unlimited)", "DZD" and the months
  // were English in every language
  testWidgets('in the manager\'s language', (tester) async {
    await pump(tester, locale: const Locale('fr'));

    expect(find.text('ACTIF'), findsOneWidget);
    expect(find.text('BROUILLON'), findsOneWidget);
    expect(find.textContaining(fr.manager), findsOneWidget);
    expect(find.textContaining(fr.restaurant), findsWidgets);
    expect(find.text('25 sept. 2026 - 31 oct. 2026'), findsOneWidget);
    expect(find.text('12 (illimité)'), findsOneWidget);
    for (final english in ['ACTIVE', 'DRAFT', '12 (unlimited)']) {
      expect(find.text(english), findsNothing, reason: english);
    }
    expect(find.textContaining('manager'), findsNothing);
  });

  testWidgets('in Arabic, the amount in dinars', (tester) async {
    await pump(tester, locale: const Locale('ar'));

    expect(find.text('300 دج'), findsOneWidget);
    expect(find.text('300 DZD'), findsNothing);
  });

  // M18: it read "Expired" all its last day, which the server still accepts
  group('an ended coupon', () {
    testWidgets('says so after its last day', (tester) async {
      await pump(tester, state: CouponsState(coupons: [ended], total: 1));

      expect(find.text('Expired'), findsOneWidget);
    });

    testWidgets('not on its last day', (tester) async {
      await pump(tester, state: CouponsState(coupons: [lastDay], total: 1));

      expect(find.text('Expired'), findsNothing);
    });
  });

  group('the list', () {
    testWidgets('loading: a spinner', (tester) async {
      await pump(
        tester,
        state: const CouponsState(isLoading: true),
        settle: false,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('nothing yet: one line for each kind', (tester) async {
      await pump(tester, state: const CouponsState());
      expect(find.text('No coupons yet'), findsOneWidget);

      await pump(
        tester,
        state: const CouponsState(),
        discountTarget: 'delivery_fee',
      );
      expect(find.text('No delivery coupons yet'), findsOneWidget);
    });

    // M19: the network's failures were written in English
    testWidgets('could not be read: why, in the manager\'s language, and '
        'a retry', (tester) async {
      await pump(
        tester,
        locale: const Locale('fr'),
        state: const CouponsState(errorMessage: 'Network connection error'),
      );
      added();

      expect(find.text(fr.errorConnectionError), findsOneWidget);
      expect(find.text('Network connection error'), findsNothing);

      await tester.tap(find.text(fr.retry));
      await tester.pump();
      expect(added(), [
        const LoadCouponsEvent(refresh: true, discountTarget: 'subtotal'),
      ]);
    });

    testWidgets('a status is asked for', (tester) async {
      await pump(tester);
      added();

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Draft').last);
      await tester.pumpAndSettle();

      expect(added(), [
        const LoadCouponsEvent(
          status: 'draft',
          refresh: true,
          discountTarget: 'subtotal',
        ),
      ]);
    });

    testWidgets('the next page comes at the bottom', (tester) async {
      await pump(
        tester,
        state: CouponsState(
          coupons: [rentree, nuit, ended, lastDay],
          lastPage: 2,
          total: 24,
        ),
      );
      added();

      await tester.fling(find.text('RENTREE10'), const Offset(0, -3000), 3000);
      await tester.pumpAndSettle();

      expect(
        added().first,
        const LoadCouponsEvent(page: 2, discountTarget: 'subtotal'),
      );
    });

    testWidgets('while it comes, a spinner below', (tester) async {
      await pump(
        tester,
        state: CouponsState(coupons: [rentree], isLoadingMore: true),
        settle: false,
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('the form', () {
    testWidgets('a coupon opens its form', (tester) async {
      await pump(tester);

      await tester.tap(find.text('RENTREE10'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditCouponScreen), findsOneWidget);
      expect(find.text('Edit Coupon'), findsOneWidget);
    });

    testWidgets('a new coupon of the page\'s kind; saved, the list is asked '
        'for again', (tester) async {
      await pump(tester, discountTarget: 'delivery_fee');
      added();

      await tester.tap(find.text('New Delivery Coupon'));
      await tester.pumpAndSettle();
      final form = tester.widget<AddEditCouponScreen>(
        find.byType(AddEditCouponScreen),
      );
      expect((form.coupon, form.discountTarget), (null, 'delivery_fee'));
      added();

      states.add(
        CouponsState(
          coupons: [rentree, nuit],
          operationStatus: CouponOperationStatus.success,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddEditCouponScreen), findsNothing);
      expect(added(), [
        const LoadCouponsEvent(refresh: true, discountTarget: 'delivery_fee'),
      ]);
      expect(
        find.byType(SnackBar),
        findsNothing,
        reason: 'the list shows the saved coupon (it was said in English)',
      );
    });
  });

  // M15: the page made a second bloc, which the filter and the next pages
  // went to: the list shown never changed
  testWidgets('one bloc for the page: the filter reaches the list shown', (
    tester,
  ) async {
    final made = <MockCouponsBloc>[];
    sl.registerFactory<CouponsBloc>(() {
      final bloc = MockCouponsBloc();
      whenListen(
        bloc,
        const Stream<CouponsState>.empty(),
        initialState: CouponsState(coupons: [rentree], total: 1),
      );
      made.add(bloc);
      return bloc;
    });
    final routes = RouteGenerator.generateRoutes();
    await pumpPage(
      tester,
      Builder(
        builder: (context) => routes[AppRoutes.restaurantCoupons]!(context),
      ),
    );

    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Active').last);
    await tester.pumpAndSettle();

    expect(made, hasLength(1));
    expect(verify(() => made.single.add(captureAny())).captured, [
      const LoadCouponsEvent(refresh: true, discountTarget: 'subtotal'),
      const LoadCouponsEvent(
        status: 'active',
        refresh: true,
        discountTarget: 'subtotal',
      ),
    ]);
  });

  group('can be read', () {
    testWidgets('in dark mode', (tester) async {
      await pump(
        tester,
        themeMode: ThemeMode.dark,
        state: CouponsState(coupons: [rentree, nuit, ended], total: 3),
      );

      expectReadable(tester);
    });

    // M20: the page stayed light grey under dark mode's black bar and dark
    // cards (its texts are on the cards, so no text was hard to read)
    testWidgets('in dark mode, on a dark page', (tester) async {
      await pump(
        tester,
        themeMode: ThemeMode.dark,
        state: CouponsState(coupons: [rentree], total: 1),
      );

      final page = find.byType(CouponsListScreen);
      final scaffold = tester.widget<Scaffold>(
        find.descendant(of: page, matching: find.byType(Scaffold)).first,
      );
      final painted =
          scaffold.backgroundColor ??
          Theme.of(tester.element(page)).scaffoldBackgroundColor;
      expect(painted.computeLuminance(), lessThan(0.1));
    });

    testWidgets('in light mode', (tester) async {
      await pump(
        tester,
        state: CouponsState(coupons: [rentree, nuit, ended], total: 3),
      );

      expectReadable(tester);
    });
  });

  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
      await pump(
        tester,
        locale: locale,
        state: CouponsState(coupons: [rentree, nuit, ended], total: 3),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
