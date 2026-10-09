import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// An account's role as the manager reads it, in the app's language (the
/// filters said "Customer", "Driver"... in every language).
String roleLabel(AppLocalizations l10n, UserRole role) => switch (role) {
  UserRole.customer => l10n.customer,
  UserRole.driver => l10n.driver,
  UserRole.restaurant => l10n.restaurant,
  UserRole.operator => l10n.operator,
  UserRole.manager => l10n.manager,
};

/// An account's status as the manager reads it, in the app's language.
String statusLabel(AppLocalizations l10n, UserStatus status) =>
    switch (status) {
      UserStatus.pendingApproval => l10n.pendingApproval,
      UserStatus.active => l10n.active,
      UserStatus.suspended => l10n.suspended,
      UserStatus.rejected => l10n.rejected,
    };
