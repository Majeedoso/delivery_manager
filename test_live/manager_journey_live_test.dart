// ignore_for_file: avoid_print
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/public_settings_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/utils/period_calculator.dart';
import 'package:delivery_manager/features/app_config/domain/repository/base_app_config_repository.dart';
import 'package:delivery_manager/features/app_version/domain/repository/base_app_version_repository.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/helpers/auth_navigation_helper.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';
import 'package:delivery_manager/features/coupons/domain/repository/base_coupons_repository.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';
import 'package:delivery_manager/features/dashboard/domain/repository/base_dashboard_repository.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/domain/repository/base_delivery_areas_repository.dart';
import 'package:delivery_manager/features/home/presentation/screens/main_screen.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/fakes.dart';
import '../test/helpers/platform.dart';

/// The manager app against a REAL backend: the manager signs in, lets new
/// accounts in or keeps them out, suspends one, runs the coupons, the
/// delivery zones and the commission, reads the day's statistics, settles
/// the platform's money both ways, and resets a forgotten password.
///
/// Everything under test/ runs on fakes. This is the layer they cannot cover:
/// the app's own wiring (ServicesLocator, the production Dio and its
/// interceptors, repositories, the auth bloc) talking to the Laravel API. Only
/// the phone is faked (storage, Firebase).
///
/// It is not part of `flutter test`: it needs a backend prepared for it, on a
/// database that can be thrown away. See test_live/README.md.
///
///   flutter test test_live --dart-define=LIVE_API=http://127.0.0.1:8011/api
const liveApi = String.fromEnvironment('LIVE_API');

/// The app's language for this run (--dart-define=LIVE_LANGUAGE=fr): the
/// server answers in it. Without it the app asks for Arabic, as a phone that
/// never chose a language does.
const liveLanguage = String.fromEnvironment(
  'LIVE_LANGUAGE',
  defaultValue: 'ar',
);

/// Where the backend's code is, to read the codes it emails (the test server
/// sends no mail).
const liveBackend = String.fromEnvironment(
  'LIVE_BACKEND',
  defaultValue: '../delivery_backend',
);

/// What the seeded database answers as the contact website: the proof that
/// the server reads a throwaway database.
const liveMarker = 'live-check.test';

/// Where the customer waits: inside the seeded delivery zone.
const doorLatitude = 36.7650;
const doorLongitude = 3.0500;

/// Where the driver stands at each step.
const driverLatitude = 36.7601;
const driverLongitude = 3.0555;

/// A repository answer, or the test fails with the reason the app would show.
T ok<T>(Either<Failure, T> result, String step) => result.fold(
  (failure) => fail('$step: ${failure.runtimeType}: ${failure.message}'),
  (value) => value,
);

/// The reason a repository gives for a refusal (the test fails if there was
/// none).
String refused<T>(Either<Failure, T> result, String step) => result.fold(
  (failure) => failure.message,
  (_) => fail('$step: the server accepted it'),
);

/// The sentence the server writes in the app's language.
String said(Map<String, String> sentences) => sentences[liveLanguage]!;

/// "2026-10-07": a day as the pages send it.
String day(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The other people in the story (customer, restaurant, drivers, operators)
/// act through the API with their own accounts, as their apps would.
class Staff {
  Staff(this.role, {String? email, this.password = 'password'})
    : email = email ?? '$role@live.test';

  final String role;
  final String email;
  String password;
  Dio _dio = Dio(
    BaseOptions(baseUrl: liveApi, headers: {'Accept': 'application/json'}),
  );

  String get _appType => role == 'colleague' ? 'operator' : role;

  /// The account's user id, from its sign-in.
  late int id;

  Future<void> signIn() async {
    final answer = await _send('POST', '/auth/login', {
      'email': email,
      'password': password,
      'app_type': _appType,
    });
    _dio.options.headers['Authorization'] = 'Bearer ${answer['data']['token']}';
    id = answer['data']['user']['id'] as int;
  }

  /// A new account: signed up with the app's form, its emailed code confirmed.
  /// It then waits for the manager.
  Future<int> signUp(String name, String phone) async {
    _dio = Dio(
      BaseOptions(baseUrl: liveApi, headers: {'Accept': 'application/json'}),
    );
    final answer = await _send('POST', '/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'role': role,
      'phone': phone,
      'app_type': _appType,
    });
    _dio.options.headers['Authorization'] = 'Bearer ${answer['data']['token']}';
    id = answer['data']['user']['id'] as int;
    await _send('POST', ApiConstance.verifyEmailOtpPath, {
      'email': email,
      'otp': await emailedCode(email),
    });
    return id;
  }

  Future<Map<String, dynamic>> get(
    String path, [
    Map<String, dynamic>? query,
  ]) => _send('GET', path, null, query);

  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic>? data,
  ]) => _send('POST', path, data);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> data) =>
      _send('PATCH', path, data);

  /// What the server answers, a refusal included: its status and its body.
  Future<(int?, Map<String, dynamic>)> attempt(
    String method,
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    final response = await _dio.request<Map<String, dynamic>>(
      path,
      data: data,
      options: Options(method: method, validateStatus: (_) => true),
    );
    return (response.statusCode, response.data ?? const <String, dynamic>{});
  }

  /// A refusal fails the test with what the server answered.
  Future<Map<String, dynamic>> _send(
    String method,
    String path, [
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  ]) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      fail(
        '$email: $method $path -> ${e.response?.statusCode} ${e.response?.data}',
      );
    }
  }
}

/// The last code the server emailed to [email] (the test server keeps it in
/// its database instead of sending it): [kind] is "verification" (sign-up)
/// or "password_reset".
Future<String> emailedCode(String email, {String kind = 'verification'}) async {
  final run = await Process.run(
    'php',
    ['tests/LiveJourney/emailed_code.php', email, kind],
    workingDirectory: liveBackend,
    runInShell: true,
  );
  expect(run.exitCode, 0, reason: 'no code for $email: ${run.stderr}');
  return '${run.stdout}'.trim();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // flutter_test answers every HTTP request itself; this run needs the network
  HttpOverrides.global = null;

  final customer = Staff('customer');
  final restaurantOwner = Staff('restaurant');
  final driver = Staff('driver');
  // The operator the prepare script created lets the customer's orders through
  final operator = Staff('colleague', email: 'operator@live.test');

  final stamp = DateTime.now().millisecondsSinceEpoch;
  const newPassword = 'Newcomer#2026x';
  final newDriver = Staff(
    'driver',
    email: 'driver.$stamp@live.test',
    password: newPassword,
  );
  final newRestaurant = Staff(
    'restaurant',
    email: 'restaurant.$stamp@live.test',
    password: newPassword,
  );
  final newOperator = Staff(
    'operator',
    email: 'operator.$stamp@live.test',
    password: newPassword,
  );
  const managerEmail = 'manager@live.test';
  const managerPassword = 'password';
  const refusalReason = 'Le registre de commerce est illisible';
  const suspensionReason = 'Trois commandes rendues sans raison';

  late int newDriverId;
  late int newRestaurantId;
  late int newOperatorId;
  late int restaurantId;
  late int margheritaId;
  late int zoneId;
  late int couponOrderId;
  late int commissionSettingId;
  late String commissionBefore;
  late int deliveredId;
  late String deliveredNumber;
  late double deliveredSubtotal;

  BaseUsersRepository users() => sl<BaseUsersRepository>();
  BaseCouponsRepository coupons() => sl<BaseCouponsRepository>();
  BaseBankRepository bank() => sl<BaseBankRepository>();

  /// Today, as the "Today" filter of the statistics and the bank counts it.
  final today = day(PeriodCalculator.calculatePeriodRange('day').startDate!);

  /// The customer orders a Margherita at the door: a new customer's order
  /// waits for an operator, who lets it through.
  Future<Map<String, dynamic>> customerOrders({String? coupon}) async {
    final placed = await customer.post('/customer/orders', {
      'restaurant_id': restaurantId,
      'items': [
        {'menu_item_id': margheritaId, 'quantity': 2, 'options': []},
      ],
      'delivery_method': 'delivery',
      'payment_method': 'cash',
      'delivery_address': 'Rue Didouche Mourad, Alger',
      'customer_name': 'Customer Live',
      'customer_phone': '0550000003',
      'delivery_latitude': doorLatitude,
      'delivery_longitude': doorLongitude,
      'coupon_code': ?coupon,
    });
    return placed['data'] as Map<String, dynamic>;
  }

  /// What the operator app sends with a confirmation: the three checks the
  /// server asks for
  const operatorChecks = {
    'customer_contacted': true,
    'customer_verified': true,
    'order_legitimate': true,
  };

  /// An order taken all the way to the customer's door, then rated. One the
  /// operator let through already is not confirmed again ([letThrough]).
  Future<void> deliver(int id, {bool letThrough = true}) async {
    if (letThrough) {
      await operator.post('/operator/orders/$id/confirm', operatorChecks);
    }
    await restaurantOwner.patch('/restaurant/orders/$id/status', {
      'status': 'restaurant_confirmed',
    });
    await driver.post('/driver/orders/$id/accept');
    for (final status in ['preparing', 'ready_for_pickup']) {
      await restaurantOwner.patch('/restaurant/orders/$id/status', {
        'status': status,
      });
    }
    for (final status in ['picked_up', 'on_delivery', 'delivered']) {
      await driver.patch('/driver/orders/$id/status', {
        'status': status,
        'driver_latitude': driverLatitude,
        'driver_longitude': driverLongitude,
      });
    }
  }

  /// What the sign-in and password screens do: the auth bloc asks the server
  /// (and keeps the token the later requests carry).
  Future<AuthState> authenticate(AuthEvent event) async {
    final bloc = sl<AuthBloc>()..add(event);
    final state = await bloc.stream
        .firstWhere((s) => s.requestState != RequestState.loading)
        .timeout(const Duration(seconds: 40));
    await bloc.close();
    return state;
  }

  /// A page of the manager's statistics, asked as the page asks it (the
  /// statistics pages call the server themselves, with the app's Dio).
  Future<Map<String, dynamic>> statistics(
    String path,
    Map<String, dynamic> query,
  ) async {
    final response = await sl<Dio>().get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    expect(response.data?['success'], isTrue, reason: path);
    return response.data!['data'] as Map<String, dynamic>;
  }

  /// Who owes the platform what, for some days or every day.
  Future<List<RestaurantDebt>> owing({String? from, String? to}) async => ok(
    await bank().getDriverBalance(from: from, to: to),
    'the balance',
  ).restaurantCredits;

  setUpAll(() async {
    expect(
      liveApi,
      isNotEmpty,
      reason: 'pass --dart-define=LIVE_API=http://host:port/api',
    );
    await initializeDateFormatting();
    Logger.level = Level.off;
    await installPlatformFakes();
    loadTestEnv(
      env: 'BASE_URL=$liveApi\nHOST_URL=${liveApi.replaceFirst('/api', '')}',
    );

    await ServicesLocator().init();
    // The language the app speaks: every request carries it
    await sl<SharedPreferences>().setString('selected_language', liveLanguage);
    // The real Firebase needs a phone; Google sign-in is not on this journey
    await sl.unregister<FirebaseAuth>();
    sl.registerLazySingleton<FirebaseAuth>(MockFirebaseAuth.new);
    await sl.unregister<GoogleSignIn>();
    sl.registerLazySingleton<GoogleSignIn>(MockGoogleSignIn.new);

    // This journey creates accounts, coupons and payments: it only runs
    // against a database seeded for it, never a real one
    final contact = await sl<BaseAppConfigRepository>().getContactInfo();
    if (contact.fold((_) => null, (info) => info.website) != liveMarker) {
      throw StateError(
        '$liveApi is not a server prepared for the live journey '
        '(see test_live/README.md). Nothing was sent to it.',
      );
    }
  });

  tearDownAll(loadTestEnv);

  group('before signing in', () {
    test('the app learns the manager app\'s version rules and the settings '
        'it needs', () async {
      final version = ok(
        await sl<BaseAppVersionRepository>().checkAppVersion(),
        'app version',
      );
      final settings = sl<PublicSettingsService>();
      await settings.refresh();

      expect(version.minimumVersion, isNotEmpty);
      expect(settings.mapToken, 'pk.live-check-token');
    });
  });

  group('the manager', () {
    test('a wrong password is refused, in the app\'s language', () async {
      final refusal = await authenticate(
        const LoginEvent(email: managerEmail, password: 'Wrong#2026x'),
      );

      expect(refusal.requestState, RequestState.error);
      expect(refusal.isAuthenticated, isFalse);
      print('  wrong password -> "${refusal.message}"');
    });

    test('signs in and lands on the home page', () async {
      final signedIn = await authenticate(
        const LoginEvent(email: managerEmail, password: managerPassword),
      );

      expect(
        signedIn.requestState,
        RequestState.loaded,
        reason: signedIn.message,
      );
      expect(signedIn.user!.role, UserRole.manager);
      expect(
        AuthNavigationHelper.getRouteForUser(signedIn.user),
        MainScreen.route,
      );

      await customer.signIn();
      await restaurantOwner.signIn();
      await driver.signIn();
      await operator.signIn();
      restaurantId =
          (await restaurantOwner.get('/restaurant/profile'))['data']['id']
              as int;
      final page = await customer.get('/customer/restaurants/$restaurantId', {
        'latitude': doorLatitude,
        'longitude': doorLongitude,
      });
      margheritaId =
          [
                for (final category in page['data']['categories'] as List)
                  ...category['menu_items'] as List,
              ].firstWhere((dish) => dish['name'] == 'Margherita')['id']
              as int;
    });
  });

  group('new accounts', () {
    test('a driver, a restaurant and an operator sign up and wait', () async {
      newDriverId = await newDriver.signUp('Sofiane Amrani', '0661234571');
      newRestaurantId = await newRestaurant.signUp('Tacos Hydra', '0661234572');
      newOperatorId = await newOperator.signUp('Lina Saadi', '0661234573');

      final waiting = ok(
        await users().getUsers(status: UserStatus.pendingApproval),
        'the accounts waiting',
      ).users;
      expect(
        waiting.map((user) => user.email),
        containsAll([newDriver.email, newRestaurant.email, newOperator.email]),
      );
      final restaurant = waiting.firstWhere((u) => u.id == newRestaurantId);
      expect(restaurant.role, UserRole.restaurant);
      expect(restaurant.emailVerifiedAt, isNotNull);
    });

    test('before the manager decides, their apps are closed to them', () async {
      final (status, body) = await newDriver.attempt('GET', '/driver/profile');

      expect(status, 403);
      expect(body['error_code'], 'ACCOUNT_NOT_APPROVED');
      expect(body['data']['status'], 'pending_approval');
    });

    test('the driver and the operator are let in', () async {
      ok(await users().approveUser(newDriverId), 'approve the driver');
      ok(await users().approveUser(newOperatorId), 'approve the operator');

      await newDriver.signIn();
      await newOperator.signIn();
      final (driverStatus, _) = await newDriver.attempt(
        'GET',
        '/driver/profile',
      );
      final (operatorStatus, _) = await newOperator.attempt(
        'GET',
        '/operator/orders/pending',
      );
      expect((driverStatus, operatorStatus), (200, 200));
    });

    test('the restaurant is refused, and its app reads why', () async {
      ok(
        await users().rejectUser(newRestaurantId, refusalReason),
        'refuse the restaurant',
      );

      final (status, body) = await newRestaurant.attempt(
        'GET',
        '/restaurant/profile',
      );
      expect(status, 403);
      expect(body['data']['status'], 'rejected');
      expect(body['data']['rejection_reason'], refusalReason);
    });

    test('an account decided already cannot be decided again', () async {
      final reason = refused(
        await users().approveUser(newDriverId),
        'approve twice',
      );

      expect(reason, isNot(contains('Exception')));
      print('  approved twice -> "$reason"');
    });

    test('the driver is suspended, then let back in', () async {
      ok(
        await users().suspendUser(newDriverId, suspensionReason),
        'suspend the driver',
      );
      final (suspended, body) = await newDriver.attempt(
        'GET',
        '/driver/profile',
      );
      expect(suspended, 403);
      expect(body['data']['status'], 'suspended');

      ok(await users().activateUser(newDriverId), 'activate the driver');
      final (back, _) = await newDriver.attempt('GET', '/driver/profile');
      expect(back, 200);
    });

    test('the list: by role, by status, by name', () async {
      final drivers = ok(
        await users().getUsers(role: UserRole.driver),
        'the drivers',
      ).users;
      final refusedOnes = ok(
        await users().getUsers(status: UserStatus.rejected),
        'the refused accounts',
      ).users;
      final found = ok(
        await users().getUsers(search: 'Lina Saadi'),
        'a name',
      ).users;

      expect(drivers.map((u) => u.id), contains(newDriverId));
      expect(drivers.every((u) => u.role == UserRole.driver), isTrue);
      expect(refusedOnes.map((u) => u.id), contains(newRestaurantId));
      expect(
        refusedOnes.firstWhere((u) => u.id == newRestaurantId).rejectionReason,
        refusalReason,
      );
      expect(found.map((u) => u.id), [newOperatorId]);
    });
  });

  group('the coupons', () {
    test('a zone around the customer\'s street, then made wider', () async {
      final zone = ok(
        await coupons().createDeliveryZone(
          name: 'Didouche $stamp',
          latitude: doorLatitude,
          longitude: doorLongitude,
          radiusKm: 0.5,
        ),
        'a new zone',
      );
      zoneId = zone.id;
      final wider = ok(
        await coupons().updateDeliveryZone(id: zoneId, radiusKm: 1.5),
        'a wider zone',
      );

      expect(zone.isActive, isTrue);
      expect(wider.radiusKm, 1.5);
    });

    test('the coupon form offers every restaurant, open or not', () async {
      final restaurants = ok(
        await coupons().getRestaurants(),
        'the restaurants',
      );

      expect(restaurants.map((r) => r['id']), contains(restaurantId));
    });

    test('a coupon for the restaurant, in that zone, takes 20 % off the '
        'customer\'s order', () async {
      final code = 'LIVE$stamp'.substring(0, 12);
      final now = DateTime.now();
      ok(
        await coupons().createCoupon(
          code: code,
          type: 'percentage',
          value: 20,
          status: 'active',
          startDate: now,
          endDate: now.add(const Duration(days: 7)),
          restaurantId: restaurantId,
          discountTarget: 'subtotal',
          deliveryZoneIds: [zoneId],
        ),
        'a new coupon',
      );

      final order = await customerOrders(coupon: code);
      couponOrderId = order['id'] as int;
      double money(String key) => double.parse('${order[key] ?? 0}');
      expect(
        money('total_amount'),
        closeTo(
          money('subtotal') * 0.8 + money('delivery_fee') + money('tax_amount'),
          1,
        ),
        reason: '20 % off the food',
      );
      await operator.post(
        '/operator/orders/${order['id']}/confirm',
        operatorChecks,
      );

      // The zone switched off: the coupon no longer applies at that door
      ok(
        await coupons().updateDeliveryZone(id: zoneId, isActive: false),
        'zone off',
      );
      final (status, body) = await customer.attempt(
        'POST',
        '/customer/orders',
        {
          'restaurant_id': restaurantId,
          'items': [
            {'menu_item_id': margheritaId, 'quantity': 1, 'options': []},
          ],
          'delivery_method': 'delivery',
          'payment_method': 'cash',
          'delivery_address': 'Rue Didouche Mourad, Alger',
          'customer_name': 'Customer Live',
          'customer_phone': '0550000003',
          'delivery_latitude': doorLatitude,
          'delivery_longitude': doorLongitude,
          'coupon_code': code,
        },
      );
      expect(status, 400);
      expect(body['error_code'], 'INVALID_COUPON');
      print('  coupon outside its zones -> "${body['message']}"');
    });
  });

  // Decision 4 of manager_suite_report.md: the app had no page for the
  // places customers can order from
  group('the delivery zones', () {
    BaseDeliveryAreasRepository zones() => sl<BaseDeliveryAreasRepository>();

    /// What the customer's app asks before an order: can it be delivered at
    /// the door?
    Future<bool> deliverableAtTheDoor() async {
      final checked = await customer.post('/customer/check-delivery-zone', {
        'latitude': doorLatitude,
        'longitude': doorLongitude,
      });
      return checked['data']['deliverable'] as bool;
    }

    test('the zone around the door, switched off: no delivery there; then '
        'on again', () async {
      final around = ok(
        await zones().getAreas(),
        'the zones',
      ).firstWhere((zone) => zone.name == 'Alger centre');
      expect(around.isActive, isTrue);
      expect(await deliverableAtTheDoor(), isTrue);

      final off = ok(await zones().switchArea(around.id), 'switch it off');
      try {
        expect(off.isActive, isFalse);
        expect(await deliverableAtTheDoor(), isFalse);
      } finally {
        // The orders after this step are delivered at that door
        final on = ok(await zones().switchArea(around.id), 'switch it on');
        expect(on.isActive, isTrue);
      }
      expect(await deliverableAtTheDoor(), isTrue);
    });

    test('a zone made, widened, then deleted', () async {
      final made = ok(
        await zones().saveArea(
          DeliveryAreaDraft(
            name: 'Bab Ezzouar $stamp',
            latitude: 36.7213,
            longitude: 3.1830,
            radiusKm: 3,
          ),
        ),
        'a new zone',
      );
      final wider = ok(
        await zones().saveArea(
          DeliveryAreaDraft(
            id: made.id,
            name: made.name,
            latitude: made.latitude,
            longitude: made.longitude,
            radiusKm: 4.5,
            isActive: made.isActive,
          ),
        ),
        'a wider zone',
      );
      ok(await zones().deleteArea(made.id), 'delete it');

      expect(
        (made.isActive, made.latitude, made.longitude),
        (true, 36.7213, 3.1830),
      );
      expect(wider.radiusKm, 4.5);
      expect(
        ok(await zones().getAreas(), 'the zones').map((zone) => zone.id),
        isNot(contains(made.id)),
      );
    });
  });

  group('the commission', () {
    test(
      'the manager raises the platform\'s share of the food to 15 %',
      () async {
        final found = ok(
          await sl<BaseDashboardRepository>().getSettings(
            search: 'system_manager_order_percentage',
          ),
          'the setting',
        );
        final setting = (found['settings'] as List<AppDashboard>).firstWhere(
          (s) => s.key == 'system_manager_order_percentage',
        );
        commissionSettingId = setting.id;
        commissionBefore = setting.value;

        final saved = ok(
          await sl<BaseDashboardRepository>().updateSetting(setting.id, '15'),
          'save 15',
        );
        expect(saved.value, '15');
      },
    );

    test(
      'an order delivered afterwards pays the platform 15 % of its food',
      () async {
        final order = await customerOrders();
        deliveredId = order['id'] as int;
        deliveredNumber = order['order_number'] as String;
        deliveredSubtotal = double.parse('${order['subtotal']}');
        await deliver(deliveredId);

        final restaurant = (await owing(from: today, to: today)).firstWhere(
          (c) =>
              c.counterpartyType == 'restaurant' &&
              c.restaurantId == restaurantId,
        );
        final share = restaurant.details.firstWhere(
          (d) => d.orderNumber == deliveredNumber,
        );
        expect(share.amount, closeTo(deliveredSubtotal * 0.15, 0.01));
      },
    );

    test('the share goes back to what it was', () async {
      ok(
        await sl<BaseDashboardRepository>().updateSetting(
          commissionSettingId,
          commissionBefore,
        ),
        'restore',
      );
    });
  });

  group('the day\'s statistics', () {
    test('the customer rates the delivered order', () async {
      await customer.post('/customer/orders/$deliveredId/rate', {
        'food_quality_rating': 5,
        'delivery_speed_rating': 4,
        'driver_rating': 5,
        'restaurant_service_rating': 4,
        'comment': 'Chaude et à l\'heure',
        'would_reorder': true,
        'would_recommend': true,
      });
    });

    test('orders, money, deliveries and ratings of today', () async {
      final orders = await statistics(ApiConstance.managerOrderStatisticsPath, {
        'date_from': today,
        'date_to': today,
      });
      final money = await statistics(ApiConstance.managerAnalyticsRevenuePath, {
        'start_date': today,
        'end_date': today,
      });
      final deliveries = await statistics(
        ApiConstance.managerDeliveryAnalyticsPath,
        {'period': 'custom', 'start_date': today, 'end_date': today},
      );
      final ratings = await statistics(
        ApiConstance.managerRatingStatisticsPath,
        {'start_date': today, 'end_date': today},
      );

      expect(orders['placed'], greaterThanOrEqualTo(2));
      expect(orders['delivered'], greaterThanOrEqualTo(1));
      expect(money['summary']['total_orders'], greaterThanOrEqualTo(1));
      expect(
        deliveries['overview']['completed_deliveries'],
        greaterThanOrEqualTo(1),
      );
      expect(ratings['overall']['total_ratings'], greaterThanOrEqualTo(1));
      print(
        '  today: ${orders['placed']} placed, ${orders['delivered']} '
        'delivered, ${money['summary']['total_revenue']} DZD',
      );
    });

    test('the restaurant\'s stars are its customers\' ratings', () async {
      final response = await sl<Dio>().get<Map<String, dynamic>>(
        ApiConstance.managerRestaurantsPath,
        queryParameters: {'per_page': 100},
      );
      final restaurant = (response.data!['data'] as List).firstWhere(
        (r) => r['id'] == restaurantId,
      );

      expect(restaurant['total_reviews'], greaterThanOrEqualTo(1));
      expect((restaurant['rating'] as num).toDouble(), greaterThan(0));
    });
  });

  group('the platform\'s money', () {
    test(
      'who owes it: the restaurant by its own id, the driver by theirs',
      () async {
        final everyone = await owing();
        final restaurant = everyone.firstWhere(
          (c) => c.counterpartyType == 'restaurant',
        );
        final theDriver = everyone.firstWhere(
          (c) => c.counterpartyType == 'driver',
        );

        expect(restaurant.restaurantId, restaurantId);
        expect(restaurant.restaurantId, isNot(restaurantOwner.id));
        expect(theDriver.restaurantId, driver.id);
        expect(restaurant.amount, greaterThan(0));
      },
    );

    test('the restaurant\'s payment, recorded: it owes nothing more', () async {
      final restaurant = (await owing()).firstWhere(
        (c) => c.counterpartyType == 'restaurant',
      );
      final due = ok(
        await bank().calculateRestaurantPaymentAmount(
          restaurantId: restaurantId,
          selectedPeriod: 'all',
        ),
        'the amount due',
      );

      ok(
        await bank().recordRestaurantPayment(
          restaurantId: restaurantId,
          amount: (due['amount'] as num).toDouble(),
          selectedPeriod: 'all',
          notes: 'Espèces remises au bureau',
        ),
        'record the payment',
      );

      expect(restaurant.amount, greaterThan(0));
      expect(
        (await owing()).where((c) => c.counterpartyType == 'restaurant'),
        isEmpty,
      );
    });

    test('the driver pays from their app; the manager confirms it', () async {
      final owed = (await owing())
          .firstWhere((c) => c.counterpartyType == 'driver')
          .amount;
      await driver.post('/driver/system-payments', {
        'amount': owed,
        'notes': 'Versement du soir',
      });

      final waiting = ok(
        await bank().getTransactions(status: 'pending'),
        'the payments waiting',
      ).transactions;
      final payment = waiting.firstWhere(
        (p) => p.transactionType == 'driver_to_system_payment',
      );
      expect(payment.amount, closeTo(owed, 0.01));
      expect(payment.notes, 'Versement du soir');

      ok(
        await bank().answerPayment(transactionId: payment.id, confirm: true),
        'confirm the payment',
      );
      expect(
        (await owing()).where((c) => c.counterpartyType == 'driver'),
        isEmpty,
      );

      // A second answer: the server says it was answered already
      final again = refused(
        await bank().answerPayment(transactionId: payment.id, confirm: false),
        'answer twice',
      );
      expect(
        again,
        said(const {
          'en': 'This payment has already been confirmed or refused.',
          'fr': 'Ce paiement a déjà été confirmé ou refusé.',
          'ar': 'سبق تأكيد هذا الدفع أو رفضه.',
        }),
      );
    });
  });

  // Decision 6 of manager_suite_report.md: what the platform owed only grew,
  // no payment from it could be recorded. Anyone may pay more than they owe,
  // the difference owed back (the owner's rule, 2026-10-08)
  group('what the platform owes', () {
    test('the coupon\'s discount owed to the restaurant, paid from the bank '
        'with 100 more: the restaurant owes the platform the 100', () async {
      // The coupon's order, let through earlier, reaches the customer: the
      // platform owes the restaurant the 20 % it took off
      await deliver(couponOrderId, letThrough: false);
      Iterable<RestaurantDebt> withTheRestaurant(List<RestaurantDebt> lines) =>
          lines.where(
            (line) =>
                line.counterpartyType == 'restaurant' &&
                line.restaurantId == restaurantId,
          );
      final before = ok(await bank().getDriverBalance(), 'the balance');
      final owed = withTheRestaurant(before.restaurantDebts).single;
      expect(owed.amount, greaterThan(0));
      // What the restaurant owes the platform meanwhile: the order's share
      final itOwed = withTheRestaurant(
        before.restaurantCredits,
      ).fold<double>(0, (sum, line) => sum + line.amount);

      final paid = ok(
        await bank().recordPlatformPayment(
          restaurantId: restaurantId,
          amount: owed.amount + 100,
          notes: 'Remise du coupon',
        ),
        'the platform pays 100 more than it owes',
      );
      expect(
        (paid.transactionType, paid.status),
        ('system_to_restaurant_payment', 'confirmed'),
      );
      final after = ok(await bank().getDriverBalance(), 'the balance');
      expect(withTheRestaurant(after.restaurantDebts), isEmpty);
      expect(
        withTheRestaurant(after.restaurantCredits).single.amount,
        closeTo(itOwed + 100, 0.01),
        reason: 'the 100 more is the restaurant\'s debt',
      );

      // The restaurant's app: the payment in its archive, and it owes the
      // platform the 100
      final archive = await restaurantOwner.get('/restaurant/transactions');
      final received = (archive['data'] as List).firstWhere(
        (transaction) => transaction['id'] == paid.id,
      );
      expect(received['transaction_type'], 'system_to_restaurant_payment');
      final balance =
          (await restaurantOwner.get('/restaurant/credits-debts'))['data']
              as Map<String, dynamic>;
      expect(
        [...?balance['credits'] as List?, ...?balance['debts'] as List?]
            .where((line) => line['counterparty_type'] == 'manager')
            .map((line) => (line['balance'] as num).toDouble()),
        [-100.0],
      );
      print(
        '  the platform paid the restaurant ${paid.amount} DZD, 100 more than '
        'it owed',
      );
    });
  });

  group('the account', () {
    test('its name and phone corrected', () async {
      final profile = sl<BaseProfileRepository>();
      ok(
        await profile.updateProfile(name: 'Karim Haddad', phone: '0550123456'),
        'save the account',
      );
      final saved = ok(await profile.getProfile(), 'the account');

      expect((saved.name, saved.phone), ('Karim Haddad', '0550123456'));
    });

    test(
      'signs out, and a forgotten password is reset by emailed code',
      () async {
        final signedOut = await authenticate(LogoutEvent());
        expect(signedOut.isAuthenticated, isFalse);

        final sent = await authenticate(
          const ResendPasswordResetOtpEvent(email: managerEmail),
        );
        expect(
          sent.requestState,
          isNot(RequestState.error),
          reason: sent.message,
        );
        final code = await emailedCode(managerEmail, kind: 'password_reset');
        final checked = await authenticate(
          VerifyPasswordResetOtpEvent(email: managerEmail, otp: code),
        );
        expect(
          checked.requestState,
          isNot(RequestState.error),
          reason: checked.message,
        );
        const fresh = 'Manager#2026x';
        final reset = await authenticate(
          ResetPasswordEvent(
            email: managerEmail,
            otp: code,
            password: fresh,
            passwordConfirmation: fresh,
          ),
        );
        expect(
          reset.requestState,
          isNot(RequestState.error),
          reason: reset.message,
        );

        final back = await authenticate(
          const LoginEvent(email: managerEmail, password: fresh),
        );
        expect(back.isAuthenticated, isTrue, reason: back.message);
      },
    );
  });
}
