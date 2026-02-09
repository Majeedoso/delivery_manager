import 'package:delivery_manager/features/bank/domain/entities/pending_payment.dart';
import 'package:delivery_manager/core/utils/currency.dart';

class PendingPaymentModel extends PendingPayment {
  const PendingPaymentModel({
    required super.transactionId,
    required super.type,
    required super.recipientName,
    required super.amount,
    required super.formattedAmount,
    super.notes,
    required super.createdAt,
    required super.formattedDate,
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

  factory PendingPaymentModel.fromJson(Map<String, dynamic> json) {
    return PendingPaymentModel(
      transactionId: json['transaction_id'] as int,
      type: json['type'] as String,
      recipientName: json['recipient_name'] as String? ?? 'Unknown',
      amount: _parseDouble(json['amount']),
      formattedAmount:
          json['formatted_amount'] as String? ?? '0.00 ${Currency.dzd.code}',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      formattedDate: json['formatted_date'] as String? ?? '',
    );
  }
}
