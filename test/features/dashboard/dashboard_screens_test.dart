import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/dashboard/data/models/app_dashboard_model.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_event.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_state.dart';
import 'package:delivery_manager/features/dashboard/presentation/screens/dashboard_category_screen.dart';
import 'package:delivery_manager/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:delivery_manager/features/dashboard/presentation/setting_texts.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fakes.dart';
import '../../helpers/pump.dart';
import '../../helpers/readable.dart';
import '../../helpers/routes.dart';

/// "Dashboard": the platform's settings, by group; each group's page shows
/// its settings, what each does (a tap) and changes one (a long tap).
void main() {
  late MockDashboardBloc dashboard;
  late StreamController<DashboardState> states;
  late RouteLog routes;
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));

  AppDashboard setting(Map<String, dynamic> json) =>
      AppDashboardModel.fromJson(json);

  final fee = setting(settingJson());
  final pricePerMeter = setting(
    settingJson(
      id: 3,
      key: 'price_per_meter',
      value: '0.02',
      typedValue: 0.02,
      description: 'Price per meter for distance calculation in DZD',
    ),
  );
  final commission = setting(
    settingJson(
      id: 4,
      key: 'system_manager_order_percentage',
      value: '10',
      typedValue: 10.0,
      category: 'financials',
      description: 'System manager percentage of order total',
    ),
  );
  final address = setting(
    settingJson(
      id: 5,
      key: 'contact_address',
      value: 'Rue Didouche Mourad, Alger',
      typedValue: 'Rue Didouche Mourad, Alger',
      type: 'string',
      category: 'legal_contact',
      description:
          'Company postal address shown on the legal pages and in the apps',
    ),
  );
  final unknown = setting(
    settingJson(
      id: 9,
      key: 'night_surcharge_percent',
      value: '15',
      typedValue: 15,
      type: 'integer',
      category: 'night_service',
      description: 'Surcharge at night',
    ),
  );

  DashboardState loaded(List<AppDashboard> settings) => DashboardState(
    settings: settings,
    settingsStatus: DashboardSettingsStatus.loaded,
  );

  setUpAll(registerFallbacks);

  setUp(() {
    dashboard = MockDashboardBloc();
    states = StreamController<DashboardState>.broadcast();
    addTearDown(states.close);
    routes = RouteLog();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    DashboardState? state,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    bool settle = true,
  }) {
    whenListen(
      dashboard,
      states.stream,
      initialState: state ?? loaded([fee, pricePerMeter, commission, address]),
    );
    return pumpPage(
      tester,
      page,
      locale: locale,
      themeMode: themeMode,
      settle: settle,
      routes: routes,
      blocs: [BlocProvider<DashboardBloc>.value(value: dashboard)],
    );
  }

  List<DashboardEvent> added() =>
      verify(() => dashboard.add(captureAny())).captured.cast<DashboardEvent>();

  group('the groups', () {
    testWidgets('asks for every setting on arrival', (tester) async {
      await pump(tester, const DashboardScreen());

      expect(added(), [const LoadSettingsEvent()]);
    });

    testWidgets('one tile per group, which opens it', (tester) async {
      await pump(tester, const DashboardScreen());

      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('Financials'), findsOneWidget);
      expect(find.text('Legal & Contact'), findsOneWidget);

      await tester.tap(find.text('Financials'));
      await tester.pumpAndSettle();
      expect(routes.names.last, AppRoutes.dashboardCategory);
      expect(routes.lastArguments, {'category': 'financials'});
    });

    // M21: the groups were named in English in every language
    testWidgets('in the manager\'s language', (tester) async {
      await pump(tester, const DashboardScreen(), locale: const Locale('fr'));

      expect(find.text(fr.settingsCategoryDelivery), findsOneWidget);
      expect(find.text(fr.settingsCategoryLegalContact), findsOneWidget);
      expect(find.text('Legal & Contact'), findsNothing);
    });

    testWidgets('a group the app has no name for shows its key, readable', (
      tester,
    ) async {
      await pump(tester, const DashboardScreen(), state: loaded([unknown]));

      expect(find.text('Night Service'), findsOneWidget);
    });

    testWidgets('could not be read: why, in the manager\'s language, and a '
        'retry', (tester) async {
      await pump(
        tester,
        const DashboardScreen(),
        locale: const Locale('fr'),
        state: const DashboardState(
          settingsStatus: DashboardSettingsStatus.error,
          errorMessage: 'Network connection error',
        ),
      );
      added();

      expect(find.text(fr.errorConnectionError), findsOneWidget);
      await tester.tap(find.text(fr.retry));
      await tester.pump();
      expect(added(), [const LoadSettingsEvent(refresh: true)]);
    });

    testWidgets('loading: a spinner', (tester) async {
      await pump(
        tester,
        const DashboardScreen(),
        state: const DashboardState(
          settingsStatus: DashboardSettingsStatus.loading,
        ),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('nothing yet', (tester) async {
      await pump(tester, const DashboardScreen(), state: loaded([]));
      expect(find.text('No settings found'), findsOneWidget);
    });

    testWidgets('can be read in dark mode', (tester) async {
      await pump(tester, const DashboardScreen(), themeMode: ThemeMode.dark);

      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}', (tester) async {
        await pump(tester, const DashboardScreen(), locale: locale);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('a group\'s page', () {
    const delivery = DashboardCategoryScreen(category: 'delivery');

    testWidgets('asks for its settings on arrival', (tester) async {
      await pump(tester, delivery, state: loaded([fee, pricePerMeter]));

      expect(added(), [const LoadSettingsEvent(category: 'delivery')]);
    });

    testWidgets('each setting: its name, its value, its kind', (tester) async {
      await pump(tester, delivery, state: loaded([fee, pricePerMeter]));

      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('Fixed delivery fee'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('Price per metre'), findsOneWidget);
      expect(find.text('0.02'), findsOneWidget);
      expect(find.text('Number'), findsNWidgets(2));
    });

    // M21: the names, the kinds and the help were English in every language
    testWidgets('in the manager\'s language', (tester) async {
      await pump(
        tester,
        delivery,
        state: loaded([fee, pricePerMeter]),
        locale: const Locale('fr'),
      );

      expect(find.text(fr.settingsCategoryDelivery), findsOneWidget);
      expect(find.text(fr.settingFixedDeliveryFeeName), findsOneWidget);
      expect(find.text(fr.settingTypeNumber), findsNWidgets(2));
      expect(find.text('Fixed Delivery Fee'), findsNothing);
      expect(find.text('decimal'), findsNothing);

      await tester.tap(find.text(fr.settingFixedDeliveryFeeName));
      await tester.pumpAndSettle();
      expect(find.text(fr.settingFixedDeliveryFeeRole), findsOneWidget);
      expect(find.text(fr.settingFixedDeliveryFeeHelp), findsOneWidget);
    });

    testWidgets('a tap explains it: what it does, its value, kind and key', (
      tester,
    ) async {
      await pump(tester, delivery, state: loaded([fee]));

      await tester.tap(find.text('Fixed delivery fee'));
      await tester.pumpAndSettle();

      expect(find.text(en.settingFixedDeliveryFeeRole), findsOneWidget);
      expect(find.text(en.settingFixedDeliveryFeeHelp), findsOneWidget);
      expect(find.text('fixed_delivery_fee'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    // M22: the help said the commission was "deducted when calculating what
    // the driver owes the restaurant"; the driver owes the whole subtotal
    testWidgets('the commission\'s help says who owes it', (tester) async {
      await pump(
        tester,
        const DashboardCategoryScreen(category: 'financials'),
        state: loaded([commission]),
      );

      await tester.tap(find.text(en.settingSystemManagerOrderPercentageName));
      await tester.pumpAndSettle();

      final help = en.settingSystemManagerOrderPercentageHelp;
      expect(find.text(help), findsOneWidget);
      expect(help, contains('owed by the restaurant to the platform'));
      expect(help, isNot(contains('deducted')));
    });

    testWidgets('a setting the app has no help for: its key, readable, and '
        'its value', (tester) async {
      await pump(
        tester,
        const DashboardCategoryScreen(category: 'night_service'),
        state: loaded([unknown]),
      );

      expect(find.text('Night Surcharge Percent'), findsOneWidget);
      await tester.tap(find.text('Night Surcharge Percent'));
      await tester.pumpAndSettle();
      expect(find.text('night_surcharge_percent'), findsOneWidget);
    });

    group('a change', () {
      Future<void> edit(WidgetTester tester, String name) async {
        await tester.longPress(find.text(name));
        await tester.pumpAndSettle();
        await tester.tap(find.text(en.editValue));
        await tester.pumpAndSettle();
      }

      testWidgets('a long tap edits the value, which is sent', (tester) async {
        await pump(tester, delivery, state: loaded([fee]));
        added();

        await edit(tester, 'Fixed delivery fee');
        expect(find.text('Fixed delivery fee in DZD'), findsOneWidget);
        await tester.enterText(find.byType(TextField), ' 200 ');
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(added(), [const UpdateSettingEvent(id: 1, value: '200')]);
      });

      testWidgets('a number left empty is not sent', (tester) async {
        await pump(tester, delivery, state: loaded([fee]));
        added();

        await edit(tester, 'Fixed delivery fee');
        await tester.enterText(find.byType(TextField), '');
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        verifyNever(() => dashboard.add(any()));
      });

      // M25: its help says to empty it to hide the address line; the empty
      // value was never sent
      testWidgets('a text can be emptied: the address, to hide it', (
        tester,
      ) async {
        await pump(
          tester,
          const DashboardCategoryScreen(category: 'legal_contact'),
          state: loaded([address]),
        );
        added();

        await edit(tester, 'Postal address');
        await tester.enterText(find.byType(TextField), '');
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(added(), [const UpdateSettingEvent(id: 5, value: '')]);
      });

      testWidgets('while it is sent, the setting waits', (tester) async {
        await pump(
          tester,
          delivery,
          state: DashboardState(
            settings: [fee],
            settingsStatus: DashboardSettingsStatus.loaded,
            updateStatus: DashboardUpdateStatus.loading,
            updatingSettingId: 1,
          ),
          settle: false,
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.tap(find.text('Fixed delivery fee'), warnIfMissed: false);
        await tester.pump();
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('saved: said once', (tester) async {
        await pump(tester, delivery, state: loaded([fee]));

        states.add(
          DashboardState(
            settings: [fee],
            settingsStatus: DashboardSettingsStatus.loaded,
            updateStatus: DashboardUpdateStatus.success,
            updatedSettingId: 1,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Setting updated successfully'), findsOneWidget);
      });

      testWidgets('refused: the server\'s reason', (tester) async {
        await pump(tester, delivery, state: loaded([fee]));

        states.add(
          DashboardState(
            settings: [fee],
            settingsStatus: DashboardSettingsStatus.loaded,
            updateStatus: DashboardUpdateStatus.error,
            updateErrorMessage:
                'Value must be a valid number for type: decimal',
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Value must be a valid number for type: decimal'),
          findsOneWidget,
        );
      });
    });

    testWidgets('could not be read: why, in the manager\'s language, and a '
        'retry', (tester) async {
      await pump(
        tester,
        delivery,
        locale: const Locale('fr'),
        state: const DashboardState(
          settingsStatus: DashboardSettingsStatus.error,
          errorMessage: 'Request timeout',
        ),
      );
      added();

      expect(find.text(fr.errorNetworkTimeout), findsOneWidget);
      await tester.tap(find.text(fr.retry));
      await tester.pump();
      expect(added(), [
        const LoadSettingsEvent(category: 'delivery', refresh: true),
      ]);
    });

    testWidgets('can be read in dark mode, its help too', (tester) async {
      await pump(tester, delivery, themeMode: ThemeMode.dark);
      expectReadable(tester);

      await tester.tap(find.text('Fixed delivery fee'));
      await tester.pumpAndSettle();
      expectReadable(tester);
    });

    for (final locale in const [Locale('fr'), Locale('ar')]) {
      testWidgets('fits a phone in ${locale.languageCode}, its help too', (
        tester,
      ) async {
        final l10n = lookupAppLocalizations(locale);
        await pump(tester, delivery, locale: locale);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(l10n.settingPricePerMeterName));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  // Every setting the server has today (47) has its texts in the three
  // languages; one added since shows its key
  test('every setting of the server has its name, its line and its help', () {
    const serverSettings = [
      'amount_rounding_step',
      'app_mapbox_access_token',
      'average_city_speed_kmh',
      'average_highway_speed_kmh',
      'best_seller_count',
      'best_seller_days',
      'best_seller_min_orders',
      'birthday_gift_cap',
      'birthday_gift_enabled',
      'city_highway_transition_km',
      'contact_address',
      'contact_email',
      'contact_phone',
      'contact_website',
      'currency',
      'customer_restaurant_prefilter_radius_km',
      'customer_restaurant_radius_km',
      'default_delivery_time_minutes',
      'fixed_delivery_fee',
      'local_timezone',
      'loyalty_coupon_validity_days',
      'loyalty_earn_rate',
      'loyalty_enabled',
      'loyalty_min_redeem_points',
      'loyalty_redeem_rate',
      'loyalty_tiers',
      'map_default_latitude',
      'map_default_longitude',
      'max_coupon_categories',
      'max_coupons_per_category',
      'max_delivery_distance_km',
      'max_driver_concurrent_orders',
      'max_items_per_order',
      'max_quantity_per_item',
      'max_saved_addresses',
      'maximum_delivery_fee',
      'min_order_scheduling_minutes',
      'minimum_delivery_fee',
      'number_of_orders_to_be_trusted',
      'otp_resend_wait_seconds',
      'otp_validity_minutes',
      'price_per_meter',
      'privacy_policy_url',
      'route_cache_minutes',
      'system_manager_delivery_fee_percentage',
      'system_manager_order_percentage',
      'terms_of_service_url',
    ];
    for (final language in ['en', 'fr', 'ar']) {
      final l10n = lookupAppLocalizations(Locale(language));
      for (final key in serverSettings) {
        final texts = settingTexts(l10n, key);
        expect(texts, isNotNull, reason: '$language $key');
        expect(
          [texts!.name, texts.role, texts.help].every((t) => t.isNotEmpty),
          isTrue,
          reason: '$language $key',
        );
      }
    }
  });
}
