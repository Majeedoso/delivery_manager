import 'package:delivery_manager/features/bank/data/models/restaurant_debt_model.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/core/utils/currency.dart';

class DriverBalanceModel extends DriverBalance {
  const DriverBalanceModel({
    required super.driverId,
    required super.driverName,
    required super.restaurantDebts,
    required super.restaurantCredits,
    required super.systemDebt,
    required super.formattedSystemDebt,
    required super.totalDebt,
    required super.formattedTotalDebt,
    required super.totalCredits,
    required super.formattedTotalCredits,
    required super.pendingPayments,
  });

  /// Safely parses a value that might be a num or a String to double
  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  factory DriverBalanceModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely map lists
    List<RestaurantDebtModel> mapList(dynamic list) {
      if (list == null || list is! List) return [];
      return list
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return RestaurantDebtModel.fromJson(item);
              }
              return null;
            } catch (e) {
              return null;
            }
          })
          .whereType<RestaurantDebtModel>()
          .toList();
    }

    final credits = mapList(json['credits']);
    final allDebts = mapList(json['debts']);

    // Separate restaurant debts from system debts
    // System debts are those where counterparty_id is 0 or name is 'System' (better check type if passed in model)
    // RestaurantDebtModel doesn't store type explicitly but stores ID/Name.
    // Assuming ID 0 is system or Name "System".

    // We can filter by checking if restaurantId == 0.
    final restaurantDebts = allDebts.where((d) => d.restaurantId != 0).toList();

    final systemDebtsList = allDebts.where((d) => d.restaurantId == 0).toList();
    // Sum system debts
    final systemDebtVal = systemDebtsList.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );

    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final totalCredits = _parseDouble(summary['total_credits']);
    final totalDebts = _parseDouble(summary['total_debts']);

    // Fallback for driver name
    final driverName = json['driver_name']?.toString() ?? 'Driver';

    return DriverBalanceModel(
      driverId: json['driver_id'] is int
          ? json['driver_id'] as int
          : int.tryParse(json['driver_id']?.toString() ?? '0') ?? 0,
      driverName: driverName,
      restaurantDebts: restaurantDebts,
      restaurantCredits: credits,
      systemDebt: systemDebtVal,
      formattedSystemDebt:
          '${systemDebtVal.toStringAsFixed(2)} ${Currency.dzd.code}',
      totalDebt: totalDebts,
      formattedTotalDebt:
          '${totalDebts.toStringAsFixed(2)} ${Currency.dzd.code}',
      totalCredits: totalCredits,
      formattedTotalCredits:
          '${totalCredits.toStringAsFixed(2)} ${Currency.dzd.code}',
      pendingPayments: [], // Not provided in new response
    );
  }
}
