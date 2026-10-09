/// Response bodies shaped like the Laravel backend's, so data sources parse
/// what the real API sends. Feature payloads (users, coupons, zones, the
/// bank...) are
/// added here as their tests are written, copied from the controllers.
library;

/// `{success: true, message, data}`, the usual Laravel success envelope.
Map<String, dynamic> ok(Object? data, {String message = 'OK'}) => {
  'success': true,
  'message': message,
  'data': data,
};

/// `{success: false, message}`, the usual error body (400/403/404/500).
Map<String, dynamic> failure(String message, {String? errorCode}) => {
  'success': false,
  'message': message,
  'error_code': ?errorCode,
};

/// A 422 body: Laravel's validation message plus one list of messages per field.
Map<String, dynamic> validationError(
  Map<String, List<String>> errors, {
  String message = 'The given data was invalid.',
}) => {'message': message, 'errors': errors};

/// The 422 of the controllers that catch the validation themselves
/// (BaseController::validationError): the same errors in the app's envelope.
Map<String, dynamic> validationFailure(
  Map<String, List<String>> errors, {
  String message = 'Validation failed',
}) => {
  'success': false,
  'message': message,
  'error_code': 'VALIDATION_ERROR',
  'errors': errors,
};

/// A Laravel paginator page (`->paginate()`), as returned inside `data`.
Map<String, dynamic> laravelPage(
  List<Object?> items, {
  int currentPage = 1,
  int lastPage = 1,
  int perPage = 15,
  int? total,
}) => {
  'data': items,
  'current_page': currentPage,
  'last_page': lastPage,
  'per_page': perPage,
  'total': total ?? items.length,
};

/// An HTML error page, like a PHP fatal error or a proxy's 502.
const htmlErrorPage =
    '<!DOCTYPE html><html><body><h1>502 Bad Gateway</h1></body></html>';

// ---------------------------------------------------------------- Auth

/// A user as the backend's UserResource sends it: the manager, approved.
Map<String, dynamic> userJson({
  int id = 7,
  String name = 'Karim Haddad',
  String email = 'karim@example.dz',
  String phone = '0550123456',
  String role = 'manager',
  String? status = 'active',
  String? emailVerifiedAt = '2026-09-01T10:00:00.000000Z',
  bool hasPassword = true,
}) => {
  'id': id,
  'name': name,
  'email': email,
  'role': role,
  'phone': phone,
  'trust_level': 'new',
  'email_verified_at': emailVerifiedAt,
  'status': status,
  'approved_by': null,
  'approved_at': null,
  'rejection_reason': null,
  'has_password': hasPassword,
  'created_at': '2026-09-01T09:00:00.000000Z',
  'updated_at': '2026-09-01T09:00:00.000000Z',
};

/// GET /auth/user's `data`, which is the manager's profile: the signed-in
/// account as UserResource sends it.
Map<String, dynamic> profileJson({
  int id = 7,
  String name = 'Karim Haddad',
  String email = 'karim@example.dz',
  String phone = '0550123456',
}) => userJson(id: id, name: name, email: email, phone: phone);

/// The login/register answer: AuthResource inside the success envelope.
Map<String, dynamic> authJson({
  Map<String, dynamic>? user,
  String token = '1|abcdef',
  String message = 'Login successful',
}) => ok({'user': user ?? userJson(), 'token': token}, message: message);

/// The answer to "send me a code": where it went and when a new one may be asked.
Map<String, dynamic> otpSentJson({
  String email = 'karim@example.dz',
  int expiresIn = 600,
  int resendCountdown = 60,
}) => ok({
  'email': email,
  'expires_in': expiresIn,
  'resend_countdown': resendCountdown,
});

// -------------------------------------------------------------- Amounts

/// An amount the way PHP's `number_format($x, 2)` writes it: "2,455.00".
String phpMoney(num amount) {
  final fixed = amount.toStringAsFixed(2);
  final whole = fixed.split('.').first;
  final grouped = whole.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '$grouped.${fixed.split('.').last}';
}

/// The number the server gives order [id] in these tests: as long as a real
/// one (ORD, the moment the order was placed and four digits, 21 characters:
/// `Order::generateOrderNumber`), so that a line too short for a real number
/// overflows here too.
String orderNumberOf(int id) =>
    'ORD20260930103000${id.toString().padLeft(4, '0')}';

// ---------------------------------------------------------------- Users

/// One account of GET /manager/users (UserManagementController::getUsers):
/// the user's columns, the role the model appends, its Spatie roles and, for
/// a customer, its trust level under `customer`.
Map<String, dynamic> managedUserJson({
  int id = 12,
  String name = 'Yacine Bouzid',
  String email = 'yacine@example.dz',
  String? phone = '0661234567',
  String role = 'driver',
  String status = 'pending_approval',
  String? emailVerifiedAt = '2026-09-29T08:00:00.000000Z',
  String? rejectionReason,
  String createdAt = '2026-09-29T07:55:00.000000Z',
}) => {
  'id': id,
  'name': name,
  'email': email,
  'phone': phone,
  'status': status,
  'google_id': null,
  'approved_by': status == 'active' ? 7 : null,
  'approved_at': status == 'active' ? '2026-09-29T09:00:00.000000Z' : null,
  'rejection_reason': rejectionReason,
  'email_verified_at': emailVerifiedAt,
  'created_at': createdAt,
  'updated_at': createdAt,
  'role': role,
  'has_password': false,
  'customer': role == 'customer' ? {'user_id': id, 'trust_level': 'new'} : null,
  'roles': [
    {'id': 3, 'name': role, 'guard_name': 'web'},
  ],
};

/// GET /manager/users: one page of accounts, and where it is in the list.
Map<String, dynamic> usersPageJson(
  List<Map<String, dynamic>> users, {
  int currentPage = 1,
  int lastPage = 1,
  int? total,
}) => ok({
  'data': users,
  'pagination': {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': 20,
    'total': total ?? users.length,
  },
}, message: 'Users retrieved successfully');

/// What an approval, a refusal, a suspension or an activation answers: the
/// account's new status (UserManagementController).
Map<String, dynamic> userDecisionJson({
  int id = 12,
  required String status,
  String? rejectionReason,
  String message = 'User approved successfully',
}) => ok({
  'id': id,
  'name': 'Yacine Bouzid',
  'email': 'yacine@example.dz',
  'status': status,
  'rejection_reason': rejectionReason,
}, message: message);

// -------------------------------------------------------------- Coupons

/// One coupon as CouponController's manager endpoints send it: its columns
/// (its days at midnight UTC), who issued it, its restaurant and its zones
/// (pivots and all), and how many times it was used.
Map<String, dynamic> couponJson({
  int id = 31,
  String code = 'RENTREE10',
  String type = 'percentage',
  int value = 10,
  String status = 'active',
  String startDate = '2026-09-25',
  String endDate = '2026-10-31',
  String discountTarget = 'subtotal',
  int? maxUsesTotal = 100,
  int? maxUsesPerCustomer = 1,
  int? minOrderValue = 1500,
  int? maxDiscountAmount = 500,
  String? description = 'The first orders of the school year',
  int usagesCount = 12,
  String issuerType = 'manager',
  Map<String, dynamic>? restaurant = const {
    'id': 4,
    'name': 'Pizzeria Le Phare',
  },
  List<Map<String, dynamic>> zones = const [],
}) => {
  'id': id,
  'code': code,
  'type': type,
  'value': value,
  'issuer_type': issuerType,
  'issuer_user_id': 7,
  'delivery_zone_ids': null,
  'status': status,
  'start_date': '${startDate}T00:00:00.000000Z',
  'end_date': '${endDate}T00:00:00.000000Z',
  'max_uses_total': maxUsesTotal,
  'max_uses_per_customer': maxUsesPerCustomer,
  'min_order_value': minOrderValue,
  'max_discount_amount': maxDiscountAmount,
  'discount_target': discountTarget,
  'is_stackable': false,
  'description': description,
  'restricted_to_customer_id': null,
  'created_at': '2026-09-24T09:00:00.000000Z',
  'updated_at': '2026-09-24T09:00:00.000000Z',
  'usages_count': usagesCount,
  'issuer': {'id': 7, 'name': 'Karim Haddad', 'role': 'manager'},
  'restaurants': [
    if (restaurant != null)
      {
        ...restaurant,
        'pivot': {'coupon_id': id, 'restaurant_id': restaurant['id']},
      },
  ],
  'coupon_zones': [
    for (final zone in zones)
      {
        'id': zone['id'],
        'name': zone['name'],
        'pivot': {'coupon_id': id, 'coupon_zone_id': zone['id']},
      },
  ],
};

/// GET /manager/coupons: Laravel's paginator inside `data`, 20 a page.
Map<String, dynamic> couponsPageJson(
  List<Map<String, dynamic>> coupons, {
  int currentPage = 1,
  int lastPage = 1,
  int? total,
}) => {
  'success': true,
  'data': laravelPage(
    coupons,
    currentPage: currentPage,
    lastPage: lastPage,
    perPage: 20,
    total: total,
  ),
};

/// A coupon zone (CouponController::managerZonesIndex): its position as the
/// decimal strings MySQL gives.
/// A delivery zone (where customers can order) as `/manager/delivery-zones`
/// sends it (DeliveryZone: MySQL's decimals as strings).
Map<String, dynamic> deliveryAreaJson({
  int id = 1,
  String name = 'Alger Centre',
  String? description = 'The Grande Poste and Didouche Mourad',
  String latitude = '36.75380000',
  String longitude = '3.05880000',
  String radiusKm = '5.00',
  bool isActive = true,
}) => {
  'id': id,
  'name': name,
  'description': description,
  'latitude': latitude,
  'longitude': longitude,
  'radius_km': radiusKm,
  'is_active': isActive,
  'created_at': '2026-09-01T08:00:00.000000Z',
  'updated_at': '2026-09-01T08:00:00.000000Z',
};

/// GET /manager/delivery-zones.
Map<String, dynamic> deliveryAreasJson(List<Map<String, dynamic>> zones) =>
    ok({'zones': zones, 'total': zones.length});

Map<String, dynamic> couponZoneJson({
  int id = 3,
  String name = 'Bab Ezzouar',
  String? description = 'Around the university',
  String? latitude = '36.7167000',
  String? longitude = '3.1833000',
  String? radiusKm = '2.50',
  bool isActive = true,
}) => {
  'id': id,
  'created_by': 7,
  'name': name,
  'description': description,
  'latitude': latitude,
  'longitude': longitude,
  'radius_km': radiusKm,
  'is_active': isActive,
};

/// One restaurant of GET /manager/restaurants (ManagerController::
/// getRestaurants): every restaurant, open or not.
Map<String, dynamic> managerRestaurantJson({
  int id = 4,
  String name = 'Pizzeria Le Phare',
  bool isOpen = false,
  String status = 'active',
}) => {
  'id': id,
  'name': name,
  'description': 'Pizzas au feu de bois',
  'phone': '0215550101',
  'email': null,
  'address': 'Rue Didouche Mourad, Alger',
  // decimal:8 columns come as strings; the rating is cast to a float
  'latitude': '36.75380000',
  'longitude': '3.05880000',
  'image': null,
  'status': status,
  'is_open': isOpen,
  'opening_hours': null,
  'rating': 4.5,
  'total_reviews': 20,
  'owner': {'id': 21, 'name': 'Samir Benali', 'email': 'samir@example.dz'},
  'performance_metrics': {
    'total_orders': 40,
    'completed_orders': 35,
    'cancelled_orders': 2,
    'pending_orders': 3,
    'total_revenue': '87,500.00',
    'average_order_value': '2,500.00',
    'completion_rate': 87.5,
    'cancellation_rate': 5.0,
    'recent_orders_30_days': 12,
  },
  'created_at': '2026-08-01T09:00:00.000000Z',
  'updated_at': '2026-09-29T09:00:00.000000Z',
};

/// GET /manager/restaurants: a page of restaurants and the platform's sums
/// (its pages beside the list, as `pagination`).
Map<String, dynamic> managerRestaurantsJson(
  List<Map<String, dynamic>> restaurants, {
  int currentPage = 1,
  int lastPage = 1,
}) => {
  'success': true,
  'message': 'Restaurants retrieved successfully',
  'data': restaurants,
  'pagination': {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': 100,
    'total': restaurants.length,
    'from': restaurants.isEmpty ? null : 1,
    'to': restaurants.length,
  },
  'summary': {
    'total_restaurants': restaurants.length,
    'active_restaurants': restaurants.length,
    'open_restaurants': 0,
    'total_orders_all_restaurants': 40,
    'total_revenue_all_restaurants': '87,500.00',
    'average_rating': 4.5,
    'top_performing_restaurant': null,
  },
};

// ------------------------------------------------------------- Settings

/// One platform setting as SettingsController sends it (its description in
/// the reader's language).
Map<String, dynamic> settingJson({
  int id = 1,
  String key = 'fixed_delivery_fee',
  String value = '150',
  Object? typedValue = 150.0,
  String type = 'decimal',
  String category = 'delivery',
  String description = 'Fixed delivery fee in DZD',
  bool isPublic = true,
}) => {
  'id': id,
  'key': key,
  'value': value,
  'typed_value': typedValue,
  'description': description,
  'type': type,
  'category': category,
  'is_public': isPublic,
  'created_at': '2026-09-01T09:00:00.000000Z',
  'updated_at': '2026-09-29T09:00:00.000000Z',
};

/// GET /manager/settings: one page of settings (50 at most).
Map<String, dynamic> settingsPageJson(
  List<Map<String, dynamic>> settings, {
  int currentPage = 1,
  int lastPage = 1,
  int? total,
}) => {
  'success': true,
  'message': 'Settings retrieved successfully',
  'data': settings,
  'pagination': {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': 50,
    'total': total ?? settings.length,
    'from': settings.isEmpty ? null : 1,
    'to': settings.length,
  },
  'filters_applied': {
    'category': null,
    'is_public': null,
    'search': null,
    'sort_by': 'category',
    'sort_order': 'asc',
  },
};

// ----------------------------------------------------------------- Bank

/// One counterparty of GET /manager/credits-debts (CashReconciliationService
/// ::getManagerCreditsAndDebts): a restaurant named by its owner's user id
/// (21) with its own id beside it, which the payment endpoints take (4); a
/// driver by their user id.
Map<String, dynamic> balanceEntryJson({
  String type = 'restaurant',
  int counterpartyId = 21,
  int restaurantId = 4,
  String name = 'Pizzeria Le Phare',
  double balance = 500,
  double? paidTowardsOrders = 0,
  List<Map<String, dynamic>> details = const [],
}) => {
  'counterparty_type': type,
  'counterparty_id': counterpartyId,
  'counterparty_name': name,
  'restaurant_id': type == 'restaurant' ? restaurantId : null,
  'credits_raw': balance,
  'debts_raw': 0.0,
  'actual_outgoing': 0.0,
  'actual_incoming': 0.0,
  'last_settlement_at': '2026-09-29T11:00:00+00:00',
  'last_transaction_at': null,
  'details': details,
  'balance': balance,
  'paid_towards_orders': paidTowardsOrders,
};

/// One line of a counterparty's details: an order's share
/// (`order_settlements`) or a payment (`cash_transactions`, with its
/// direction), dated by the server in UTC.
Map<String, dynamic> balanceDetailJson({
  String source = 'order_settlements',
  String? direction,
  int id = 1,
  double amount = 500,
  String reason = 'settlement',
  String fullDate = '2026-09-29T11:00:00+00:00',
}) => {
  'source': source,
  'direction': ?direction,
  'id': id,
  'amount': amount,
  'reason': reason,
  'order_number': source == 'order_settlements' ? orderNumberOf(id) : null,
  'date': fullDate.substring(0, 10),
  'full_date': fullDate,
};

/// GET /manager/credits-debts's data: who owes the platform (credits) and
/// whom it owes (debts), with their sums. driver_id and driver_name are the
/// manager's (the app reads the answer with the driver's model).
Map<String, dynamic> managerBalanceJson({
  List<Map<String, dynamic>> credits = const [],
  List<Map<String, dynamic>> debts = const [],
}) {
  double sum(List<Map<String, dynamic>> entries) =>
      entries.fold(0.0, (total, e) => total + (e['balance'] as num));
  return {
    'currency': 'DZD',
    'credits': credits,
    'debts': debts,
    'summary': {
      'total_credits': sum(credits),
      'total_debts': sum(debts),
      'net_balance': sum(credits) - sum(debts),
    },
    'driver_id': 1,
    'driver_name': 'Karim Haddad',
  };
}

/// A payment a driver or a restaurant sent to the platform, as GET
/// /manager/system-payments lists it (TransactionResource): the payer (a
/// restaurant's owner, Samir, or a driver, Yacine), the restaurant's own name
/// for a restaurant's, the answer and the manager who gave it.
Map<String, dynamic> systemPaymentJson({
  int id = 70,
  String type = 'restaurant_to_system_payment',
  double amount = 500,
  String status = 'pending',
  String? notes = 'Cash given at the office',
  String? responseNotes,
  String createdAt = '2026-09-30T09:15:00.000000Z',
  String? confirmedAt,
  String? confirmedBy,
}) {
  final restaurant = type == 'restaurant_to_system_payment';
  // What the platform paid a restaurant or a driver (decision 6)
  final fromPlatform = type.startsWith('system_to_');
  final toRestaurant = type == 'system_to_restaurant_payment';
  return {
    'id': id,
    'transaction_type': type,
    'transaction_type_display': null,
    'from_user': fromPlatform
        ? {'id': 1, 'name': 'Karim Haddad', 'role': 'manager'}
        : restaurant
        ? {'id': 21, 'name': 'Samir Benali', 'role': 'restaurant'}
        : {'id': 25, 'name': 'Yacine Bouzid', 'role': 'driver'},
    'to_user': fromPlatform
        ? toRestaurant
              ? {'id': 21, 'name': 'Samir Benali', 'role': 'restaurant'}
              : {'id': 25, 'name': 'Yacine Bouzid', 'role': 'driver'}
        : confirmedBy != null && restaurant
        ? {'id': 1, 'name': confirmedBy, 'role': 'manager'}
        : {'id': null, 'name': 'Unknown', 'role': null},
    'amount': amount,
    'formatted_amount': '${phpMoney(amount)} DZD',
    'currency': 'DZD',
    'status': status,
    'status_display': status[0].toUpperCase() + status.substring(1),
    'notes': notes,
    'response_notes': responseNotes,
    'restaurant_name': restaurant || toRestaurant ? 'Pizzeria Le Phare' : null,
    if (confirmedBy != null)
      'confirmed_by': {'id': 1, 'name': confirmedBy, 'role': 'manager'},
    'confirmed_at': confirmedAt,
    'start_date': null,
    'end_date': null,
    'created_at': createdAt,
    'updated_at': confirmedAt ?? createdAt,
    'summary': null,
  };
}

/// GET /manager/system-payments: one page of payments, the newest first.
Map<String, dynamic> systemPaymentsPageJson(
  List<Map<String, dynamic>> payments, {
  int currentPage = 1,
  int lastPage = 1,
}) => {
  'success': true,
  'message': 'System payments retrieved successfully',
  'data': payments,
  'pagination': {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': 15,
    'total': payments.length,
    'from': payments.isEmpty ? null : 1,
    'to': payments.length,
    'has_more_pages': currentPage < lastPage,
  },
};

/// GET /manager/restaurant-payment-amount and system-payment-amount: what is
/// due for the days chosen. While a payment they sent waits for the manager,
/// has_existing_transaction (the restaurant's amount then reads 0).
Map<String, dynamic> paymentAmountJson({
  double amount = 500,
  bool waiting = false,
}) => ok({
  'amount': amount,
  'formatted_amount': '${phpMoney(amount)} DZD',
  'has_existing_transaction': waiting,
  'existing_transaction_status': waiting ? 'pending' : null,
}, message: 'Amount calculated successfully');

// ----------------------------------------------------------- Statistics

/// GET /manager/analytics/revenue (ManagerController::getRevenueSummary): the
/// money of the orders delivered in the days asked, written as PHP's
/// number_format writes it. Six orders of 2,000: the platform takes 10 % of
/// the food (1,050) and 20 % of the delivery fees (300).
Map<String, dynamic> revenueSummaryJson({
  num totalRevenue = 12000,
  num subtotalRevenue = 10500,
  num deliveryFees = 1500,
  num platformRevenue = 1350,
  num driverEarnings = 1200,
  num restaurantEarnings = 9450,
  int totalOrders = 6,
  num averageOrderValue = 2000,
}) => {
  'success': true,
  'message': 'Revenue summary retrieved successfully',
  'data': {
    'summary': {
      'total_revenue': phpMoney(totalRevenue),
      'subtotal_revenue': phpMoney(subtotalRevenue),
      'delivery_fees': phpMoney(deliveryFees),
      'platform_revenue': phpMoney(platformRevenue),
      'driver_earnings': phpMoney(driverEarnings),
      'restaurant_earnings': phpMoney(restaurantEarnings),
      'net_profit': phpMoney(platformRevenue),
      'total_orders': totalOrders,
      'average_order_value': phpMoney(averageOrderValue),
      'date_range': {
        'type': 'custom_range',
        'start_date': '2026-09-27',
        'end_date': '2026-09-30',
        'description': 'Revenue from 2026-09-27 to 2026-09-30',
      },
    },
    'breakdowns': {
      'payment_methods': <String, dynamic>{},
      'restaurants': <Object>[],
      'drivers': <Object>[],
      'time_periods': <Object>[],
    },
    'top_performers': {'restaurant': null, 'driver': null, 'best_day': null},
    'growth_metrics': <String, dynamic>{},
  },
};

/// One driver of GET /manager/drivers (ManagerController::getAllDrivers): a
/// user (its id is the user's), with the figures the lists show.
Map<String, dynamic> managerDriverJson({
  int id = 25,
  String name = 'Yacine Bouzid',
  int totalDeliveries = 40,
  double completionRate = 95.0,
  double averageRating = 4.6,
  double averageDriverRating = 4.7,
  int totalDriverRatings = 18,
}) => {
  'id': id,
  'name': name,
  'email': 'driver$id@example.dz',
  'created_at': '2026-08-01 09:00:00',
  'updated_at': '2026-09-29 09:00:00',
  'status': 'active',
  'is_online': true,
  'current_assignments': 0,
  'performance_metrics': {
    'total_deliveries': totalDeliveries,
    'completed_deliveries': (totalDeliveries * completionRate / 100).round(),
    'cancelled_deliveries': 2,
    'total_earnings': phpMoney(totalDeliveries * 150),
    'average_delivery_time_minutes': 24.5,
    'average_distance_km': 3.2,
    'average_rating': averageRating,
    'total_ratings': totalDriverRatings,
    'rating_info': {
      'average_driver_rating': averageDriverRating,
      'total_driver_ratings': totalDriverRatings,
      'rating_distribution': {'1': 0, '2': 0, '3': 1, '4': 4, '5': 13},
      'has_ratings': totalDriverRatings > 0,
    },
    'completion_rate': completionRate,
    'cancellation_rate': 5.0,
    'recent_deliveries_30_days': 12,
  },
  'earnings_info': <Object>[],
};

/// GET /manager/drivers: a page of drivers, its pages beside the list
/// (`pagination`).
Map<String, dynamic> managerDriversJson(
  List<Map<String, dynamic>> drivers, {
  int currentPage = 1,
  int lastPage = 1,
}) => {
  'success': true,
  'message': 'Drivers retrieved successfully',
  'data': drivers,
  'pagination': {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': 10,
    'total': drivers.length,
    'from': drivers.isEmpty ? null : 1,
    'to': drivers.length,
  },
  'summary': {
    'total_drivers': drivers.length,
    'active_drivers': drivers.length,
    'inactive_drivers': 0,
    'total_deliveries_all_drivers': 40,
  },
};

/// GET /manager/statistics/orders: the orders placed in the days asked, by
/// where each is now (12 in all).
Map<String, dynamic> orderStatisticsJson({
  int placed = 12,
  int pendingVerification = 1,
  int acceptedByOperator = 1,
  int acceptedByRestaurant = 2,
  int rejectedByOperator = 1,
  int rejectedByRestaurant = 1,
  int acceptedByDriver = 2,
  int cancelled = 1,
  int delivered = 3,
}) => ok({
  'placed': placed,
  'pending_verification': pendingVerification,
  'accepted_by_operator': acceptedByOperator,
  'accepted_by_restaurant': acceptedByRestaurant,
  'rejected_by_operator': rejectedByOperator,
  'rejected_by_restaurant': rejectedByRestaurant,
  'accepted_by_driver': acceptedByDriver,
  'cancelled': cancelled,
  'delivered': delivered,
  'period': {'from': '2026-09-27', 'to': '2026-09-30'},
}, message: 'Order statistics retrieved successfully');

/// GET /manager/deliveries/analytics: the deliveries of the days asked, every
/// driver's or one's (driver_id).
Map<String, dynamic> deliveryAnalyticsJson({
  int totalDeliveries = 20,
  int completedDeliveries = 18,
  int cancelledDeliveries = 2,
  double completionRate = 90.0,
  double averageDeliveryTime = 27.5,
  double onTimeDeliveryRate = 85.0,
  double fastestDelivery = 12.0,
  double slowestDelivery = 48.0,
  double responseSpeed = 2.5,
  double pickupSpeed = 6.0,
  double cancellationRate = 10.0,
}) => {
  'success': true,
  'message': 'Delivery analytics retrieved successfully',
  'data': {
    'period': {
      'type': 'custom',
      'start_date': '2026-09-27',
      'end_date': '2026-09-30',
    },
    'overview': {
      'total_deliveries': totalDeliveries,
      'completed_deliveries': completedDeliveries,
      'cancelled_deliveries': cancelledDeliveries,
      'completion_rate': completionRate,
      'average_delivery_time_minutes': averageDeliveryTime,
      'total_distance_km': 64.0,
    },
    'performance_metrics': {
      'fastest_delivery_minutes': fastestDelivery,
      'slowest_delivery_minutes': slowestDelivery,
      'average_distance_per_delivery': 3.2,
      'on_time_delivery_rate': onTimeDeliveryRate,
      'response_speed_minutes': responseSpeed,
      'pickup_speed_minutes': pickupSpeed,
      'cancellation_rate': cancellationRate,
    },
    'driver_performance': <Object>[],
    'daily_trends': <Object>[],
    'insights': <Object>[],
  },
};

/// GET /manager/restaurants/statistics/overview and
/// /manager/restaurants/{id}/statistics: the orders of the days asked by the
/// restaurants' decision, and how fast and how well they decide (a speed is
/// null while no order has one).
Map<String, dynamic> restaurantStatisticsJson({
  int pending = 2,
  int accepted = 9,
  int rejected = 1,
  int delivered = 7,
  double? responseSpeed = 1.5,
  double? preparationSpeed = 14.2,
  double decisionQuality = 87.5,
  double poorDecisions = 12.5,
}) => ok({
  'order_counts': {
    'pending': pending,
    'accepted': accepted,
    'rejected': rejected,
    'delivered': delivered,
  },
  'performance': {
    'response_speed': responseSpeed,
    'preparation_speed': preparationSpeed,
    'decision_quality': decisionQuality,
    'poor_decisions': poorDecisions,
  },
  'period': {
    'type': 'custom',
    'start_date': '2026-09-27',
    'end_date': '2026-09-30',
  },
}, message: 'Global restaurant statistics retrieved successfully');

/// GET /manager/ratings/statistics: the ratings given in the days asked.
Map<String, dynamic> ratingStatisticsJson({
  int totalRatings = 20,
  double averageRating = 4.35,
  double foodQuality = 4.5,
  double restaurantService = 4.2,
  double driverRating = 4.6,
  double deliverySpeed = 4.4,
  double reorderRate = 85.0,
  double recommendationRate = 90.0,
}) => ok({
  'period': {'start_date': '2026-09-27', 'end_date': '2026-09-30'},
  'overall': {
    'total_ratings': totalRatings,
    'average_rating': averageRating,
    'rating_distribution': {'1': 1, '2': 0, '3': 2, '4': 6, '5': 11},
  },
  'restaurant_performance': {
    'total_restaurant_ratings': totalRatings,
    'average_restaurant_rating': averageRating,
    'average_food_quality_rating': foodQuality,
    'average_restaurant_service_rating': restaurantService,
  },
  'driver_performance': {
    'total_driver_ratings': 18,
    'average_driver_rating': driverRating,
    'average_delivery_speed_rating': deliverySpeed,
  },
  'customer_satisfaction': {
    'reorder_rate': reorderRate,
    'recommendation_rate': recommendationRate,
  },
  'top_performers': {'restaurants': <Object>[], 'drivers': <Object>[]},
}, message: 'Rating statistics retrieved successfully');

/// One review of GET /manager/drivers/{id}/ratings or /restaurants/{id}/ratings
/// (an OrderRating with its customer, restaurant and order), rated at 00:30 on
/// Wednesday in Algiers: 23:30 on Tuesday on the server's clock.
Map<String, dynamic> reviewJson({
  int id = 90,
  int overall = 5,
  int? driverRating = 5,
  String? comment = 'Rapide et chaud',
  String? driverComment = 'Très poli',
  String ratedAt = '2026-09-29T23:30:00.000000Z',
}) => {
  'id': id,
  'order_id': 31,
  'customer_id': 12,
  'restaurant_id': 4,
  'driver_id': 25,
  'overall_rating': overall,
  'food_quality_rating': 5,
  'delivery_speed_rating': 4,
  'driver_rating': driverRating,
  'restaurant_service_rating': 4,
  'comment': comment,
  'food_comment': null,
  'delivery_comment': null,
  'driver_comment': driverComment,
  'restaurant_comment': null,
  'would_reorder': true,
  'would_recommend': true,
  'rated_at': ratedAt,
  'customer': {'id': 12, 'name': 'Amina Kaci'},
  'restaurant': {'id': 4, 'name': 'Pizzeria Le Phare'},
  'order': {'id': 31, 'order_number': orderNumberOf(31)},
};

/// One driver's or restaurant's reviews (ApiResponse, with `meta`: the page
/// and the averages; a driver's are named "driver_").
Map<String, dynamic> reviewsPageJson(
  List<Map<String, dynamic>> reviews, {
  bool ofDriver = true,
  int currentPage = 1,
  int lastPage = 1,
}) => {
  'success': true,
  'message': ofDriver
      ? 'Driver ratings retrieved successfully'
      : 'Restaurant ratings retrieved successfully',
  'data': reviews,
  'meta': {
    'pagination': {
      'current_page': currentPage,
      'per_page': 20,
      'total': reviews.length,
      'last_page': lastPage,
      'from': reviews.isEmpty ? null : 1,
      'to': reviews.length,
      'has_more_pages': currentPage < lastPage,
    },
    'statistics': ofDriver
        ? {
            'average_driver_rating': 4.7,
            'total_driver_ratings': reviews.length,
            'rating_distribution': {'1': 0, '2': 0, '3': 0, '4': 1, '5': 3},
          }
        : {
            'average_rating': 4.5,
            'total_ratings': reviews.length,
            'rating_distribution': {'1': 0, '2': 0, '3': 1, '4': 1, '5': 2},
          },
  },
};
