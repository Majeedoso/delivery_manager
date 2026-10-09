import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/core/utils/app_navigator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/app_config/domain/entities/contact_info.dart';
import 'package:delivery_manager/features/app_config/domain/entities/legal_urls.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_contact_info_usecase.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_parameters.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_usecase.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/features/app_version/presentation/screens/update_required_screen.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/account_status_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/reset_password_unauthenticated_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/verify_email_otp_screen.dart';
import 'package:delivery_manager/features/bank/data/models/driver_balance_model.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/features/bank/presentation/screens/bank_archive_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/bank_main_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/driver_debt_details_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/new_transaction_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/receivables_payables_screen.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/coupons_home_screen.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/coupons_list_screen.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/delivery_zones_screen.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_bloc.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_event.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_state.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/screens/delivery_areas_screen.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_event.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_state.dart';
import 'package:delivery_manager/features/dashboard/presentation/screens/dashboard_category_screen.dart';
import 'package:delivery_manager/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:delivery_manager/features/home/presentation/screens/main_screen.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/localization/presentation/screens/first_run_language_screen.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_email_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_password_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/profile_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/reset_password_authenticated_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/verify_delete_account_otp_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/verify_email_change_otp_screen.dart';
import 'package:delivery_manager/features/settings/presentation/screens/about_screen.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_main_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_driver_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_restaurant_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_restaurants_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_money_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_restaurants_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_orders_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_driver_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_restaurant_detail_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_restaurants_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_performance_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_drivers_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_overview_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_restaurants_screen.dart';
import 'package:delivery_manager/features/statistics/presentation/screens/statistics_ratings_screen.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_bloc.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_event.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_state.dart';
import 'package:delivery_manager/features/users/presentation/screens/users_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';
import '../../helpers/fakes.dart';
import '../../helpers/locator.dart';
import '../../helpers/pump.dart';
import '../../helpers/routes.dart';

class _MockGetLegalUrlsUseCase extends Mock implements GetLegalUrlsUseCase {}

class _MockGetContactInfoUseCase extends Mock
    implements GetContactInfoUseCase {}

class _MockAuthLocalDataSource extends Mock
    implements BaseAuthLocalDataSource {}

/// Every name in the route table builds its screen with the blocs and
/// services the app gives it. A route whose builder throws, or reads a bloc
/// nobody provides, only fails when the manager taps their way to it.
void main() {
  setUpAll(() {
    registerFallbacks();
    registerFallbackValue(const NoParameters());
    registerFallbackValue(const GetLegalUrlsParameters());
  });

  late List<BlocProvider> appBlocs;
  late MockProfileBloc profile;
  late MockUsersBloc users;
  late MockCouponsBloc coupons;
  late MockDashboardBloc dashboard;
  late MockBankBloc bank;
  late MockDeliveryAreasBloc deliveryAreas;

  setUp(() async {
    T stub<T extends BlocBase<S>, S>(T bloc, S state) {
      whenListen(bloc as dynamic, Stream<S>.empty(), initialState: state);
      return bloc;
    }

    final auth = stub<MockAuthBloc, AuthState>(
      MockAuthBloc(),
      const AuthState(
        requestState: RequestState.loaded,
        user: User(
          id: 1,
          name: 'Karim Haddad',
          email: 'karim@example.dz',
          phone: '0550123456',
          role: UserRole.manager,
          status: 'active',
        ),
        isAuthenticated: true,
      ),
    );
    // What main.dart puts above every page
    appBlocs = [
      BlocProvider<LocalizationBloc>.value(
        value: stub<MockLocalizationBloc, LocalizationState>(
          MockLocalizationBloc(),
          const LocalizationState(firstRunCheckCompleted: true),
        ),
      ),
      BlocProvider<ThemeBloc>.value(
        value: stub<MockThemeBloc, ThemeState>(
          MockThemeBloc(),
          const ThemeState(currentTheme: ThemeMode.light),
        ),
      ),
      BlocProvider<AuthBloc>.value(value: auth),
      BlocProvider<CountdownBloc>.value(
        value: stub<MockCountdownBloc, CountdownState>(
          MockCountdownBloc(),
          const CountdownState(),
        ),
      ),
    ];

    // Blocs a route or a screen creates itself
    registerBloc<AuthBloc>(auth);
    registerBloc<ProfileBloc>(
      profile = stub<MockProfileBloc, ProfileState>(
        MockProfileBloc(),
        const ProfileState(),
      ),
    );
    registerBloc<AppVersionBloc>(
      stub<MockAppVersionBloc, AppVersionState>(
        MockAppVersionBloc(),
        const AppVersionState(),
      ),
    );
    registerBloc<UsersBloc>(
      users = stub<MockUsersBloc, UsersState>(
        MockUsersBloc(),
        const UsersState(),
      ),
    );
    registerBloc<DeliveryAreasBloc>(
      deliveryAreas = stub<MockDeliveryAreasBloc, DeliveryAreasState>(
        MockDeliveryAreasBloc(),
        const DeliveryAreasState(),
      ),
    );
    registerBloc<CouponsBloc>(
      coupons = stub<MockCouponsBloc, CouponsState>(
        MockCouponsBloc(),
        const CouponsState(),
      ),
    );
    registerBloc<DashboardBloc>(
      dashboard = stub<MockDashboardBloc, DashboardState>(
        MockDashboardBloc(),
        const DashboardState(),
      ),
    );
    registerBloc<BankBloc>(
      bank = stub<MockBankBloc, BankState>(MockBankBloc(), const BankInitial()),
    );

    final legalUrls = _MockGetLegalUrlsUseCase();
    when(() => legalUrls(any())).thenAnswer(
      (_) async => const Right(
        LegalUrls(privacyPolicyUrl: null, termsOfServiceUrl: null),
      ),
    );
    final contact = _MockGetContactInfoUseCase();
    when(() => contact(any())).thenAnswer(
      (_) async =>
          const Right(ContactInfo(email: null, phone: null, website: null)),
    );
    final loadCredentials = MockLoadCredentialsUseCase();
    when(
      () => loadCredentials(any()),
    ).thenAnswer((_) async => const Right({'email': null, 'rememberMe': null}));
    registerUseCase<GetLegalUrlsUseCase>(legalUrls);
    registerUseCase<GetContactInfoUseCase>(contact);
    registerUseCase<LoadCredentialsUseCase>(loadCredentials);
    registerUseCase<SaveCredentialsUseCase>(MockSaveCredentialsUseCase());

    final local = _MockAuthLocalDataSource();
    when(() => local.getCurrentUser()).thenAnswer((_) async => null);
    registerService<BaseAuthLocalDataSource>(local);
    // The statistics pages ask the server themselves
    final backend = FakeBackend()
      ..reply('GET', '/manager/analytics/revenue', body: revenueSummaryJson())
      ..reply('GET', '/manager/statistics/orders', body: orderStatisticsJson())
      ..reply(
        'GET',
        '/manager/ratings/statistics',
        body: ratingStatisticsJson(),
      )
      ..reply(
        'GET',
        '/manager/deliveries/analytics',
        body: deliveryAnalyticsJson(),
      )
      ..reply(
        'GET',
        '/manager/restaurants/statistics/overview',
        body: restaurantStatisticsJson(),
      )
      ..reply(
        'GET',
        '/manager/restaurants/4/statistics',
        body: restaurantStatisticsJson(),
      )
      ..reply(
        'GET',
        '/manager/restaurants',
        body: managerRestaurantsJson([managerRestaurantJson()]),
      )
      ..reply(
        'GET',
        '/manager/drivers',
        body: managerDriversJson([managerDriverJson()]),
      );
    registerService<Dio>(testDio(backend));
    SharedPreferences.setMockInitialValues({});
    registerService<SharedPreferences>(await SharedPreferences.getInstance());
  });

  const appVersion = AppVersion(
    minimumVersion: '1.2.0',
    currentVersion: '1.2.0',
  );
  final pizzeria = DriverBalanceModel.fromJson(
    managerBalanceJson(credits: [balanceEntryJson()]),
  ).restaurantCredits.single;
  const yacine = <String, dynamic>{'id': 25, 'name': 'Yacine Bouzid'};
  const lePhare = <String, dynamic>{'id': 4, 'name': 'Pizzeria Le Phare'};

  /// Each route with the arguments the app pushes it with, and its screen.
  final routes = <String, (Object?, Type)>{
    AppRoutes.firstRunLanguage: (null, FirstRunLanguageScreen),
    AppRoutes.login: (null, LoginScreen),
    AppRoutes.forgotPassword: (null, ForgotPasswordScreen),
    AppRoutes.resetPasswordUnauthenticated: (
      <String, String>{'email': 'karim@example.dz', 'otp': '123456'},
      ResetPasswordUnauthenticatedScreen,
    ),
    AppRoutes.accountStatus: (null, AccountStatusScreen),
    AppRoutes.verifyEmailOtp: (
      <String, dynamic>{'email': 'karim@example.dz'},
      VerifyEmailOtpScreen,
    ),
    AppRoutes.updateRequired: (
      <String, dynamic>{
        'appVersion': appVersion,
        'userCurrentVersion': '1.1.0',
      },
      UpdateRequiredScreen,
    ),
    AppRoutes.main: (null, MainScreen),
    AppRoutes.profile: (null, ProfileScreen),
    AppRoutes.editProfile: (null, EditProfileScreen),
    AppRoutes.changePassword: (null, ChangePasswordScreen),
    AppRoutes.changeEmail: (null, ChangeEmailScreen),
    AppRoutes.verifyEmailChangeOtp: (
      <String, dynamic>{'newEmail': 'new@example.dz'},
      VerifyEmailChangeOtpScreen,
    ),
    AppRoutes.resetPasswordAuthenticated: (
      null,
      ResetPasswordAuthenticatedScreen,
    ),
    AppRoutes.verifyDeleteAccountOtp: (null, VerifyDeleteAccountOtpScreen),
    AppRoutes.settings: (null, SettingsScreen),
    AppRoutes.about: (null, AboutScreen),
    AppRoutes.bank: (null, BankMainScreen),
    AppRoutes.bankReceivables: (null, ReceivablesPayablesScreen),
    AppRoutes.bankNewTransaction: (null, NewTransactionScreen),
    AppRoutes.bankArchive: (null, BankArchiveScreen),
    AppRoutes.driverDebtDetails: (
      <String, dynamic>{
        'item': pizzeria,
        'period': 'all',
        'dateFrom': null,
        'dateTo': null,
      },
      DriverDebtDetailsScreen,
    ),
    AppRoutes.statistics: (null, StatisticsMainScreen),
    AppRoutes.statisticsMoney: (null, StatisticsMoneyScreen),
    AppRoutes.statisticsMoneyOverview: (null, StatisticsMoneyOverviewScreen),
    AppRoutes.statisticsMoneyRestaurants: (
      null,
      StatisticsMoneyRestaurantsScreen,
    ),
    AppRoutes.statisticsMoneyRestaurantDetail: (
      lePhare,
      StatisticsMoneyRestaurantDetailScreen,
    ),
    AppRoutes.statisticsMoneyDrivers: (null, StatisticsMoneyDriversScreen),
    AppRoutes.statisticsMoneyDriverDetail: (
      yacine,
      StatisticsMoneyDriverDetailScreen,
    ),
    AppRoutes.statisticsOrders: (null, StatisticsOrdersScreen),
    AppRoutes.statisticsOrdersOverview: (null, StatisticsOrdersOverviewScreen),
    AppRoutes.statisticsOrdersRestaurants: (
      null,
      StatisticsOrdersRestaurantsScreen,
    ),
    AppRoutes.statisticsOrdersDrivers: (null, StatisticsOrdersDriversScreen),
    AppRoutes.statisticsRatings: (null, StatisticsRatingsScreen),
    AppRoutes.statisticsRatingsOverview: (
      null,
      StatisticsRatingsOverviewScreen,
    ),
    AppRoutes.statisticsRatingsRestaurants: (
      null,
      StatisticsRatingsRestaurantsScreen,
    ),
    AppRoutes.statisticsRatingsDrivers: (null, StatisticsRatingsDriversScreen),
    AppRoutes.statisticsPerformance: (null, StatisticsPerformanceScreen),
    AppRoutes.statisticsPerformanceOverview: (
      null,
      StatisticsPerformanceOverviewScreen,
    ),
    AppRoutes.statisticsPerformanceRestaurants: (
      null,
      StatisticsPerformanceRestaurantsScreen,
    ),
    AppRoutes.statisticsPerformanceRestaurantDetail: (
      lePhare,
      StatisticsPerformanceRestaurantDetailScreen,
    ),
    AppRoutes.statisticsPerformanceDrivers: (
      null,
      StatisticsPerformanceDriversScreen,
    ),
    AppRoutes.statisticsPerformanceDriverDetail: (
      yacine,
      StatisticsPerformanceDriverDetailScreen,
    ),
    AppRoutes.coupons: (null, CouponsHomeScreen),
    AppRoutes.restaurantCoupons: (null, CouponsListScreen),
    AppRoutes.deliveryCoupons: (null, CouponsListScreen),
    AppRoutes.globalCoupons: (null, CouponsListScreen),
    AppRoutes.deliveryZones: (null, DeliveryZonesScreen),
    AppRoutes.deliveryAreas: (null, DeliveryAreasScreen),
    AppRoutes.users: (null, UsersScreen),
    AppRoutes.dashboard: (null, DashboardScreen),
    AppRoutes.dashboardCategory: (
      <String, dynamic>{'category': 'delivery'},
      DashboardCategoryScreen,
    ),
  };

  Future<void> openRoute(
    WidgetTester tester,
    String route, [
    Object? arguments,
  ]) async {
    await pumpPage(
      tester,
      const SizedBox(),
      blocs: appBlocs,
      onGenerateRoute: appRoute,
      settle: false,
    );
    navigatorKey.currentState!.pushNamed(route, arguments: arguments);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// The app drawn again under the open page, as when the manager changes
  /// the language or the theme: MaterialApp builds every open route anew.
  Future<void> redrawApp(WidgetTester tester) async {
    await pumpPage(
      tester,
      const SizedBox(),
      locale: const Locale('fr'),
      blocs: appBlocs,
      onGenerateRoute: appRoute,
      settle: false,
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  routes.forEach((route, expected) {
    final (arguments, screen) = expected;

    testWidgets('$route builds $screen', (tester) async {
      await openRoute(tester, route, arguments);

      expect(tester.takeException(), isNull);
      expect(find.byType(screen), findsOneWidget);

      // Some screens wait a moment before their first step
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('a page\'s own version check', () {
    // The splash checks the version as it opens; the settings only when the
    // manager asks
    for (final (route, atOnce) in [
      (AppRoutes.splash, 1),
      (AppRoutes.settings, 0),
    ]) {
      testWidgets('$route: never made twice, and ended with the page', (
        tester,
      ) async {
        final made = <MockAppVersionBloc>[];
        await sl.unregister<AppVersionBloc>();
        sl.registerFactory<AppVersionBloc>(() {
          final bloc = MockAppVersionBloc();
          whenListen(
            bloc,
            const Stream<AppVersionState>.empty(),
            initialState: const AppVersionState(),
          );
          made.add(bloc);
          return bloc;
        });

        await openRoute(tester, route);
        await redrawApp(tester);

        expect(
          made,
          hasLength(atOnce),
          reason: 'each redraw of the app made another one',
        );

        navigatorKey.currentState!.pop();
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 3));

        for (final bloc in made) {
          verify(() => bloc.close()).called(1);
        }
      });
    }
  });

  group('a page asks for its data once, and not again at a redraw', () {
    // Typed: through `dynamic`, the matcher reached add() as null and the
    // call was never recorded
    Future<void> asksOnce<E extends Object>(
      WidgetTester tester,
      String route,
      Bloc<E, Object?> bloc,
      E expected, [
      Object? arguments,
    ]) async {
      await openRoute(tester, route, arguments);

      final asked = verify(() => bloc.add(captureAny<E>())).captured;
      expect(asked, [expected], reason: route);

      await redrawApp(tester);
      verifyNever(() => bloc.add(any<E>()));
    }

    testWidgets('the account to edit', (tester) async {
      await asksOnce(
        tester,
        AppRoutes.editProfile,
        profile,
        const GetProfileEvent(),
      );
    });

    testWidgets('the users', (tester) async {
      await asksOnce(tester, AppRoutes.users, users, const LoadUsersEvent());
    });

    testWidgets('the platform\'s settings', (tester) async {
      await asksOnce(
        tester,
        AppRoutes.dashboard,
        dashboard,
        const LoadSettingsEvent(),
      );
    });

    testWidgets('the delivery zones', (tester) async {
      await asksOnce(
        tester,
        AppRoutes.deliveryAreas,
        deliveryAreas,
        const LoadDeliveryAreasEvent(),
      );
    });

    testWidgets('a kind of coupon', (tester) async {
      await asksOnce(
        tester,
        AppRoutes.deliveryCoupons,
        coupons,
        const LoadCouponsEvent(refresh: true, discountTarget: 'delivery_fee'),
      );
    });

    testWidgets('the payments sent from the apps', (tester) async {
      await asksOnce(
        tester,
        AppRoutes.bankArchive,
        bank,
        const GetTransactionsEvent(),
      );
    });
  });

  test('every route the table knows is opened above', () {
    // Read from the sources: AppRoutes' names and values, and the names the
    // table uses
    final values = {
      for (final m in RegExp(
        r'''static const String (\w+) =\s*['"]([^'"]+)['"];''',
      ).allMatches(File('lib/core/routes/app_routes.dart').readAsStringSync()))
        m[1]!: m[2]!,
    };
    final generated = {
      for (final m in RegExp(r'AppRoutes\.(\w+): \(context\)').allMatches(
        File('lib/core/routes/route_generator.dart').readAsStringSync(),
      ))
        values[m[1]!]!,
    };

    // The splash route is tested with the app (its bloc runs for real)
    expect(generated, hasLength(greaterThan(40)), reason: 'the table was read');
    expect({...routes.keys, AppRoutes.splash}, containsAll(generated));
  });
}
