import 'package:flutter/material.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class UserListItem extends StatelessWidget {
  final ManagedUser user;
  final bool isUpdating;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onSuspend;
  final VoidCallback? onActivate;

  const UserListItem({
    super.key,
    required this.user,
    this.isUpdating = false,
    this.onApprove,
    this.onReject,
    this.onSuspend,
    this.onActivate,
  });

  Color _getRoleColor() {
    switch (user.role) {
      case UserRole.customer:
        return Colors.blue;
      case UserRole.driver:
        return Colors.purple;
      case UserRole.restaurant:
        return Colors.green;
      case UserRole.operator:
        return Colors.orange;
      case UserRole.manager:
        return Colors.red;
    }
  }

  IconData _getRoleIcon() {
    switch (user.role) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.driver:
        return Icons.delivery_dining;
      case UserRole.restaurant:
        return Icons.restaurant;
      case UserRole.operator:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.manage_accounts;
    }
  }

  Color _getStatusColor(UserStatus status) {
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

  IconData _getStatusIcon(UserStatus status) {
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

  void _handleStatusChange(UserStatus selectedStatus) {
    // Determine which action to call based on current and selected status
    if (selectedStatus == user.status) {
      return; // No change needed
    }

    switch (selectedStatus) {
      case UserStatus.active:
        // Can activate from suspended or approve from pending
        if (user.status == UserStatus.suspended && onActivate != null) {
          onActivate!();
        } else if (user.status == UserStatus.pendingApproval &&
            onApprove != null) {
          onApprove!();
        }
        break;

      case UserStatus.rejected:
        if (onReject != null) {
          onReject!();
        }
        break;

      case UserStatus.suspended:
        if (onSuspend != null) {
          onSuspend!();
        }
        break;

      case UserStatus.pendingApproval:
        // Cannot change back to pending approval
        break;
    }
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return DropdownButton2<UserStatus>(
      value: user.status,
      hint: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            localizations.changeStatus,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      items: UserStatus.values.map((status) {
        final color = _getStatusColor(status);
        return DropdownMenuItem<UserStatus>(
          value: status,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getStatusIcon(status), size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                status.displayName,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: isUpdating
          ? null
          : (status) {
              if (status != null) {
                _handleStatusChange(status);
              }
            },
      underline: const SizedBox.shrink(),
      buttonStyleData: ButtonStyleData(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        offset: const Offset(0, -4),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Opacity(
        opacity: isUpdating ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRoleColor().withOpacity(0.1),
                    child: Icon(
                      _getRoleIcon(),
                      color: _getRoleColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isUpdating)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.phone,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (user.emailVerifiedAt == null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.emailNotVerified,
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (user.rejectionReason != null &&
                  user.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.rejectionReason!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildStatusDropdown(context),
            ],
          ),
        ),
      ),
    );
  }
}
