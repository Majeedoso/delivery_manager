class PendingPayment {
  final int transactionId;
  final String type;
  final String recipientName;
  final double amount;
  final String formattedAmount;
  final String? notes;
  final DateTime createdAt;
  final String formattedDate;

  const PendingPayment({
    required this.transactionId,
    required this.type,
    required this.recipientName,
    required this.amount,
    required this.formattedAmount,
    this.notes,
    required this.createdAt,
    required this.formattedDate,
  });

  bool get isRestaurantPayment => type == 'driver_to_restaurant_payment';
  bool get isSystemPayment => type == 'driver_to_system_payment';
}
