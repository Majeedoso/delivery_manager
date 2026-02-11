import 'package:delivery_manager/features/bank/data/models/driver_credit_debt_detail_model.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';
import 'package:delivery_manager/core/utils/currency.dart';

class RestaurantDebtModel extends RestaurantDebt {
  const RestaurantDebtModel({
    required super.restaurantId,
    required super.restaurantName,
    required super.amount,
    required super.formattedAmount,
    super.isCredit,
    super.counterpartyType,
    super.confirmedAt,
    super.details,
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

  factory RestaurantDebtModel.fromJson(Map<String, dynamic> json) {
    // Handle both old and new API formats
    // New format uses 'balance' instead of 'amount'
    // New format uses 'counterparty_id' instead of 'restaurant_id'

    final balancedRaw = json['balance'] ?? json['amount'];
    final double rawAmount = _parseDouble(balancedRaw);
    final double amount = rawAmount.abs(); // Keep amount positive

    final id = json['counterparty_id'] ?? json['restaurant_id'] ?? 0;
    final name =
        json['counterparty_name'] ?? json['restaurant_name'] ?? 'Unknown';
    final typeRaw = json['counterparty_type'] ?? json['type'];
    final counterpartyType = typeRaw?.toString() ??
        ((id is int ? id : int.tryParse(id.toString()) ?? 0) == 0
            ? 'system'
            : 'restaurant');

    // Attempt to parse a date
    DateTime? confirmedAt;
    final dateRaw =
        json['last_settlement_at'] ??
        json['last_transaction_at'] ??
        json['confirmed_at'];
    if (dateRaw != null) {
      if (dateRaw is String) {
        confirmedAt = DateTime.tryParse(dateRaw);
      } else if (dateRaw is DateTime) {
        confirmedAt = dateRaw;
      }
    }

    // Parse details if available
    final detailsList =
        (json['details'] as List<dynamic>?)
            ?.map((e) => DriverCreditDebtDetailModel.fromJson(e))
            .toList() ??
        [];

    return RestaurantDebtModel(
      restaurantId: id is int ? id : int.tryParse(id.toString()) ?? 0,
      restaurantName: name.toString(),
      amount: amount,
      formattedAmount:
          json['formatted_amount'] as String? ??
          '${amount.toStringAsFixed(2)} ${Currency.dzd.code}',
      isCredit: rawAmount > 0, // Heuristic, or passed parameter
      counterpartyType: counterpartyType,
      confirmedAt: confirmedAt,
      details: detailsList,
    );
  }
}
