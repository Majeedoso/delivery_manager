import 'package:flutter/material.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class UserFiltersSection extends StatelessWidget {
  final UserRole? selectedRole;
  final UserStatus? selectedStatus;
  final Function(UserRole?) onRoleChanged;
  final Function(UserStatus?) onStatusChanged;

  const UserFiltersSection({
    super.key,
    this.selectedRole,
    this.selectedStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                Text(
                  localizations.filters,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField2<UserRole?>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text(
                      localizations.allRoles,
                      style: const TextStyle(fontSize: 14),
                    ),
                    items: [
                      DropdownMenuItem<UserRole?>(
                        value: null,
                        child: Text(localizations.allRoles),
                      ),
                      ...UserRole.values
                          .where((role) => role != UserRole.manager)
                          .map((role) {
                            return DropdownMenuItem<UserRole?>(
                              value: role,
                              child: Text(_getRoleDisplayName(role)),
                            );
                          }),
                    ],
                    onChanged: onRoleChanged,
                    buttonStyleData: const ButtonStyleData(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField2<UserStatus?>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text(
                      localizations.allStatuses,
                      style: const TextStyle(fontSize: 14),
                    ),
                    items: [
                      DropdownMenuItem<UserStatus?>(
                        value: null,
                        child: Text(localizations.allStatuses),
                      ),
                      ...UserStatus.values.map((status) {
                        return DropdownMenuItem<UserStatus?>(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }),
                    ],
                    onChanged: onStatusChanged,
                    buttonStyleData: const ButtonStyleData(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.driver:
        return 'Driver';
      case UserRole.restaurant:
        return 'Restaurant';
      case UserRole.operator:
        return 'Operator';
      case UserRole.manager:
        return 'Manager';
    }
  }
}
