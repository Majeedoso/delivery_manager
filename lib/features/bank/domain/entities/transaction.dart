class Transaction {
  final int id;
  final String transactionType;
  final double amount;
  final String formattedAmount;
  final String status;
  final String? notes;
  final int fromUserId;
  final String? fromUserName;
  final int toUserId;
  final String? toUserName;
  final int? restaurantId;
  final String? restaurantName;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final int? confirmedBy;
  final String? confirmedByName;
  final bool senderApproved;
  final bool recipientApproved;
  final DateTime? senderApprovedAt;
  final DateTime? recipientApprovedAt;

  const Transaction({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.formattedAmount,
    required this.status,
    this.notes,
    required this.fromUserId,
    this.fromUserName,
    required this.toUserId,
    this.toUserName,
    this.restaurantId,
    this.restaurantName,
    required this.createdAt,
    this.confirmedAt,
    this.confirmedBy,
    this.confirmedByName,
    required this.senderApproved,
    required this.recipientApproved,
    this.senderApprovedAt,
    this.recipientApprovedAt,
  });
}
