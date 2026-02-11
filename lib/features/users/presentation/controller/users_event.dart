import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';

abstract class UsersEvent {
  const UsersEvent();
}

class LoadUsersEvent extends UsersEvent {
  final bool showLoading;

  const LoadUsersEvent({this.showLoading = true});
}

class LoadMoreUsersEvent extends UsersEvent {
  const LoadMoreUsersEvent();
}

class FilterUsersEvent extends UsersEvent {
  final UserRole? role;
  final UserStatus? status;

  const FilterUsersEvent({this.role, this.status});
}

class ApproveUserEvent extends UsersEvent {
  final int userId;

  const ApproveUserEvent(this.userId);
}

class RejectUserEvent extends UsersEvent {
  final int userId;
  final String reason;

  const RejectUserEvent(this.userId, this.reason);
}

class SuspendUserEvent extends UsersEvent {
  final int userId;
  final String reason;

  const SuspendUserEvent(this.userId, this.reason);
}

class ActivateUserEvent extends UsersEvent {
  final int userId;

  const ActivateUserEvent(this.userId);
}

class ClearUsersFeedbackEvent extends UsersEvent {
  const ClearUsersFeedbackEvent();
}

class SearchUsersEvent extends UsersEvent {
  final String query;

  const SearchUsersEvent(this.query);
}
