enum RequestState { initial, loading, loaded, error }

enum UserRole { customer, restaurant, driver, manager, operator }

extension UserRoleExtension on UserRole {
  /// Get the role name as a string
  String get roleName => toString().split('.').last;
}
