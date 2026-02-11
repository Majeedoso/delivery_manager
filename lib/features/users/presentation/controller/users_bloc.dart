import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/features/users/domain/usecases/get_users_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/approve_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/reject_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/suspend_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/activate_user_usecase.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_event.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;
  final ApproveUserUseCase approveUserUseCase;
  final RejectUserUseCase rejectUserUseCase;
  final SuspendUserUseCase suspendUserUseCase;
  final ActivateUserUseCase activateUserUseCase;
  final LoggingService _logger;

  UsersBloc({
    required this.getUsersUseCase,
    required this.approveUserUseCase,
    required this.rejectUserUseCase,
    required this.suspendUserUseCase,
    required this.activateUserUseCase,
    LoggingService? logger,
  })  : _logger = logger ?? sl<LoggingService>(),
        super(const UsersState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<FilterUsersEvent>(_onFilterUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<ApproveUserEvent>(_onApproveUser);
    on<RejectUserEvent>(_onRejectUser);
    on<SuspendUserEvent>(_onSuspendUser);
    on<ActivateUserEvent>(_onActivateUser);
    on<ClearUsersFeedbackEvent>(_onClearFeedback);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (event.showLoading) {
      emit(
        state.copyWith(
          requestState: RequestState.loading,
          errorMessage: '',
          resetAction: true,
        ),
      );
    }

    final result = await getUsersUseCase(
      page: 1,
      perPage: 20,
      role: state.selectedRole,
      status: state.selectedStatus,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    );

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to load users', error: failure);
        emit(
          state.copyWith(
            requestState: RequestState.error,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (paginatedUsers) {
        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            users: paginatedUsers.users,
            currentPage: paginatedUsers.currentPage,
            hasMorePages: paginatedUsers.hasMorePages,
            isLoadingMore: false,
            errorMessage: '',
            resetAction: true,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    emit(
      state.copyWith(isLoadingMore: true, errorMessage: '', resetAction: true),
    );

    final nextPage = state.currentPage + 1;
    final result = await getUsersUseCase(
      page: nextPage,
      perPage: 20,
      role: state.selectedRole,
      status: state.selectedStatus,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    );

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to load more users', error: failure);
        emit(
          state.copyWith(
            isLoadingMore: false,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (data) {
        emit(
          state.copyWith(
            users: [...state.users, ...data.users],
            currentPage: data.currentPage,
            hasMorePages: data.hasMorePages,
            isLoadingMore: false,
            errorMessage: '',
            resetAction: true,
          ),
        );
      },
    );
  }

  Future<void> _onFilterUsers(
    FilterUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    // Update filters and reload
    emit(
      state.copyWith(
        requestState: RequestState.loading,
        selectedRole: event.role,
        selectedStatus: event.status,
        clearRoleFilter: event.role == null,
        clearStatusFilter: event.status == null,
        resetAction: true,
      ),
    );

    final result = await getUsersUseCase(
      page: 1,
      perPage: 20,
      role: event.role,
      status: event.status,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    );

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to filter users', error: failure);
        emit(
          state.copyWith(
            requestState: RequestState.error,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (paginatedUsers) {
        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            users: paginatedUsers.users,
            currentPage: paginatedUsers.currentPage,
            hasMorePages: paginatedUsers.hasMorePages,
            errorMessage: '',
            resetAction: true,
          ),
        );
      },
    );
  }

  Future<void> _onApproveUser(
    ApproveUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state.updatingIds.contains(event.userId)) return;

    final updatingIds = Set<int>.from(state.updatingIds)..add(event.userId);
    emit(
      state.copyWith(
        updatingIds: updatingIds,
        errorMessage: '',
        resetAction: true,
      ),
    );

    final result = await approveUserUseCase(event.userId);
    if (emit.isDone) return;

    final updatedIds = Set<int>.from(state.updatingIds)..remove(event.userId);

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to approve user', error: failure);
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            action: UsersAction.approved,
            errorMessage: '',
          ),
        );
        // Refresh list
        add(const LoadUsersEvent(showLoading: false));
      },
    );
  }

  Future<void> _onRejectUser(
    RejectUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state.updatingIds.contains(event.userId)) return;

    final updatingIds = Set<int>.from(state.updatingIds)..add(event.userId);
    emit(
      state.copyWith(
        updatingIds: updatingIds,
        errorMessage: '',
        resetAction: true,
      ),
    );

    final result = await rejectUserUseCase(event.userId, event.reason);
    if (emit.isDone) return;

    final updatedIds = Set<int>.from(state.updatingIds)..remove(event.userId);

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to reject user', error: failure);
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            action: UsersAction.rejected,
            errorMessage: '',
          ),
        );
        // Refresh list
        add(const LoadUsersEvent(showLoading: false));
      },
    );
  }

  Future<void> _onSuspendUser(
    SuspendUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state.updatingIds.contains(event.userId)) return;

    final updatingIds = Set<int>.from(state.updatingIds)..add(event.userId);
    emit(
      state.copyWith(
        updatingIds: updatingIds,
        errorMessage: '',
        resetAction: true,
      ),
    );

    final result = await suspendUserUseCase(event.userId, event.reason);
    if (emit.isDone) return;

    final updatedIds = Set<int>.from(state.updatingIds)..remove(event.userId);

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to suspend user', error: failure);
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            action: UsersAction.suspended,
            errorMessage: '',
          ),
        );
        // Refresh list
        add(const LoadUsersEvent(showLoading: false));
      },
    );
  }

  Future<void> _onActivateUser(
    ActivateUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    if (state.updatingIds.contains(event.userId)) return;

    final updatingIds = Set<int>.from(state.updatingIds)..add(event.userId);
    emit(
      state.copyWith(
        updatingIds: updatingIds,
        errorMessage: '',
        resetAction: true,
      ),
    );

    final result = await activateUserUseCase(event.userId);
    if (emit.isDone) return;

    final updatedIds = Set<int>.from(state.updatingIds)..remove(event.userId);

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to activate user', error: failure);
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            updatingIds: updatedIds,
            action: UsersAction.activated,
            errorMessage: '',
          ),
        );
        // Refresh list
        add(const LoadUsersEvent(showLoading: false));
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    // Update search query and reload
    emit(
      state.copyWith(
        requestState: RequestState.loading,
        searchQuery: event.query,
        resetAction: true,
      ),
    );

    final result = await getUsersUseCase(
      page: 1,
      perPage: 20,
      role: state.selectedRole,
      status: state.selectedStatus,
      search: event.query.isEmpty ? null : event.query,
    );

    result.fold(
      (failure) {
        _logger.error('UsersBloc: Failed to search users', error: failure);
        emit(
          state.copyWith(
            requestState: RequestState.error,
            errorMessage: failure.message,
            resetAction: true,
          ),
        );
      },
      (paginatedUsers) {
        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            users: paginatedUsers.users,
            currentPage: paginatedUsers.currentPage,
            hasMorePages: paginatedUsers.hasMorePages,
            errorMessage: '',
            resetAction: true,
          ),
        );
      },
    );
  }

  void _onClearFeedback(
    ClearUsersFeedbackEvent event,
    Emitter<UsersState> emit,
  ) {
    emit(state.copyWith(errorMessage: '', resetAction: true));
  }
}
