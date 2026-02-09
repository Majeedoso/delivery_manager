import 'package:delivery_manager/features/bank/domain/entities/driver_credit_debt_detail.dart';

class DriverCreditDebtDetailModel extends DriverCreditDebtDetail {
  const DriverCreditDebtDetailModel({
    required super.source,
    super.direction,
    required super.id,
    required super.amount,
    required super.date,
    super.type,
    super.transactionType,
    super.reason,
    super.orderNumber,
  });

  factory DriverCreditDebtDetailModel.fromJson(Map<String, dynamic> json) {
    return DriverCreditDebtDetailModel(
      source: json['source'] ?? '',
      direction: json['direction'],
      id: json['id'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date:
          json['full_date'] ??
          json['date'] ??
          '', // Try to use full_date if available
      type: json['type'],
      transactionType: json['transaction_type'],
      reason: json['reason'],
      orderNumber: json['order_number']?.toString(),
    );
  }
}
