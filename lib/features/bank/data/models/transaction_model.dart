import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/core/utils/currency.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.transactionType,
    required super.amount,
    required super.formattedAmount,
    required super.status,
    super.notes,
    required super.fromUserId,
    super.fromUserName,
    required super.toUserId,
    super.toUserName,
    super.restaurantId,
    super.restaurantName,
    required super.createdAt,
    super.confirmedAt,
    super.confirmedBy,
    super.confirmedByName,
    required super.senderApproved,
    required super.recipientApproved,
    super.senderApprovedAt,
    super.recipientApprovedAt,
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

  /// Safely parses a value that might be an int, num, String, or map with id
  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is Map<String, dynamic>) {
      final nested = value['id'];
      if (nested is int) return nested;
      if (nested is num) return nested.toInt();
      if (nested is String) return int.tryParse(nested) ?? defaultValue;
    }
    return defaultValue;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final amount = _parseDouble(json['amount']);
    return TransactionModel(
      id: _parseInt(json['id']),
      transactionType:
          json['transaction_type'] as String? ?? json['type'] as String? ?? '',
      amount: amount,
      formattedAmount:
          json['formatted_amount'] as String? ??
          '${amount.toStringAsFixed(2)} ${Currency.dzd.code}',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      fromUserId: _parseInt(json['from_user_id']) != 0
          ? _parseInt(json['from_user_id'])
          : _parseInt(json['from_user']),
      fromUserName:
          json['from_user']?['name'] as String? ??
          json['from_user_name'] as String?,
      toUserId: _parseInt(json['to_user_id']) != 0
          ? _parseInt(json['to_user_id'])
          : _parseInt(json['to_user']),
      toUserName:
          json['to_user']?['name'] as String? ??
          json['to_user_name'] as String?,
      restaurantId: _parseInt(json['restaurant_id']) != 0
          ? _parseInt(json['restaurant_id'])
          : null,
      restaurantName: json['restaurant_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      confirmedBy: _parseInt(json['confirmed_by']) != 0
          ? _parseInt(json['confirmed_by'])
          : null,
      confirmedByName: json['confirmed_by_user']?['name'] as String?,
      senderApproved: json['sender_approved'] as bool? ?? false,
      recipientApproved: json['recipient_approved'] as bool? ?? false,
      senderApprovedAt: json['sender_approved_at'] != null
          ? DateTime.parse(json['sender_approved_at'] as String)
          : null,
      recipientApprovedAt: json['recipient_approved_at'] != null
          ? DateTime.parse(json['recipient_approved_at'] as String)
          : null,
    );
  }
}
