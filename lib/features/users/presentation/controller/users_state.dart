import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';

enum UsersAction {
  approved,
  rejected,
  suspended,
  activated,
}

class UsersState {
  final RequestState requestState;
  final List<ManagedUser> users;
  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;
  final Set<int> updatingIds;
  final String errorMessage;
  final UsersAction? action;

  // Current filters
  final UserRole? selectedRole;
  final UserStatus? selectedStatus;
  final String searchQuery;

  const UsersState({
    this.requestState = RequestState.loading,
    this.users = const [],
    this.currentPage = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
    this.updatingIds = const {},
    this.errorMessage = '',
    this.action,
    this.selectedRole,
    this.selectedStatus,
    this.searchQuery = '',
  });

  UsersState copyWith({
    RequestState? requestState,
    List<ManagedUser>? users,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
    Set<int>? updatingIds,
    String? errorMessage,
    UsersAction? action,
    bool resetAction = false,
    UserRole? selectedRole,
    UserStatus? selectedStatus,
    bool clearRoleFilter = false,
    bool clearStatusFilter = false,
    String? searchQuery,
  }) {
    return UsersState(
      requestState: requestState ?? this.requestState,
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      updatingIds: updatingIds ?? this.updatingIds,
      errorMessage: errorMessage ?? this.errorMessage,
      action: resetAction ? null : (action ?? this.action),
      selectedRole:
          clearRoleFilter ? null : (selectedRole ?? this.selectedRole),
      selectedStatus:
          clearStatusFilter ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
