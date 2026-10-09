/// Builders for domain objects with readable defaults, so a test names only
/// the fields it is about. Grows one feature at a time.
library;

/// A fixed instant, so nothing in a test depends on the real clock:
/// noon on 30 September 2026 (the last day of a month, on purpose).
final testNow = DateTime(2026, 9, 30, 12);

/// The server's clock is UTC; screens show the phone's. This is "HH:mm" on
/// this machine for a time the server wrote as [serverTime] ("2026-09-30
/// 11:40:00", or an ISO text), so tests pass in any time zone.
String localTime(String serverTime) {
  final text = serverTime.contains('T')
      ? serverTime
      : '${serverTime.replaceFirst(' ', 'T')}Z';
  final local = DateTime.parse(text).toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------- Orders

/// Every status the backend's `orders.status` enum can hold.
const backendOrderStatuses = [
  'pending_verification',
  'operator_confirmed',
  'operator_rejected',
  'restaurant_confirmed',
  'restaurant_rejected',
  'preparing',
  'ready_for_pickup',
  'driver_assigned',
  'picked_up',
  'on_delivery',
  'driver_arrived',
  'delivered',
  'cancelled_by_customer',
  'cancelled_by_operator',
  'cancelled_by_manager',
  'refunded',
];

/// The statuses after which nothing more happens to an order: the backend's
/// `Order::FINAL_STATUSES`.
const finalOrderStatuses = [
  'delivered',
  'operator_rejected',
  'restaurant_rejected',
  'cancelled_by_customer',
  'cancelled_by_operator',
  'cancelled_by_manager',
  'refunded',
];
