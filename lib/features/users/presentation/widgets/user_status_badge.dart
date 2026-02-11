import 'package:flutter/material.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';

class UserStatusBadge extends StatelessWidget {
  final UserStatus status;

  const UserStatusBadge({
    super.key,
    required this.status,
  });

  Color _getBackgroundColor() {
    switch (status) {
      case UserStatus.pendingApproval:
        return Colors.orange.withOpacity(0.12);
      case UserStatus.active:
        return Colors.green.withOpacity(0.12);
      case UserStatus.suspended:
        return Colors.red.withOpacity(0.12);
      case UserStatus.rejected:
        return Colors.grey.withOpacity(0.12);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case UserStatus.pendingApproval:
        return Colors.orange;
      case UserStatus.active:
        return Colors.green;
      case UserStatus.suspended:
        return Colors.red;
      case UserStatus.rejected:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case UserStatus.pendingApproval:
        return Icons.pending;
      case UserStatus.active:
        return Icons.check_circle;
      case UserStatus.suspended:
        return Icons.block;
      case UserStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 16,
            color: _getTextColor(),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
