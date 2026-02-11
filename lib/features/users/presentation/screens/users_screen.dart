import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_bloc.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_event.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_state.dart';
import 'package:delivery_manager/features/users/presentation/widgets/user_list_item.dart';
import 'package:delivery_manager/features/users/presentation/widgets/user_filters_section.dart';
import 'package:delivery_manager/features/users/presentation/widgets/reject_user_dialog.dart';
import 'package:delivery_manager/features/users/presentation/widgets/suspend_user_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRejectDialog(BuildContext context, ManagedUser user) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => RejectUserDialog(userName: user.name),
    ).then((reason) {
      if (reason != null && reason.isNotEmpty) {
        context.read<UsersBloc>().add(RejectUserEvent(user.id, reason));
      }
    });
  }

  void _showSuspendDialog(BuildContext context, ManagedUser user) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SuspendUserDialog(userName: user.name),
    ).then((reason) {
      if (reason != null && reason.isNotEmpty) {
        context.read<UsersBloc>().add(SuspendUserEvent(user.id, reason));
      }
    });
  }

  void _showActionSnackbar(BuildContext context, UsersAction action) {
    final localizations = AppLocalizations.of(context)!;
    String message;
    IconData icon;
    Color color;

    switch (action) {
      case UsersAction.approved:
        message = localizations.userApprovedSuccessfully;
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case UsersAction.rejected:
        message = localizations.userRejectedSuccessfully;
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case UsersAction.suspended:
        message = localizations.userSuspendedSuccessfully;
        icon = Icons.block;
        color = Colors.orange;
        break;
      case UsersAction.activated:
        message = localizations.userActivatedSuccessfully;
        icon = Icons.check_circle;
        color = Colors.green;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userManagement),
        elevation: 0,
      ),
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) {
          // Show success messages
          if (state.action != null) {
            _showActionSnackbar(context, state.action!);
            context.read<UsersBloc>().add(const ClearUsersFeedbackEvent());
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<UsersBloc>().add(const LoadUsersEvent());
            },
            child: Column(
              children: [
                UserFiltersSection(
                  selectedRole: state.selectedRole,
                  selectedStatus: state.selectedStatus,
                  onRoleChanged: (role) {
                    context.read<UsersBloc>().add(
                          FilterUsersEvent(
                            role: role,
                            status: state.selectedStatus,
                          ),
                        );
                  },
                  onStatusChanged: (status) {
                    context.read<UsersBloc>().add(
                          FilterUsersEvent(
                            role: state.selectedRole,
                            status: status,
                          ),
                        );
                  },
                ),
                _buildSearchBar(context, state),
                Expanded(
                  child: _buildContent(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, UsersState state) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: localizations.searchUsers,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<UsersBloc>().add(const SearchUsersEvent(''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          // Debounce search to avoid too many API calls
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            if (_searchController.text == value) {
              context.read<UsersBloc>().add(SearchUsersEvent(value));
            }
          });
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, UsersState state) {
    if (state.requestState == RequestState.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.requestState == RequestState.error) {
      final localizations = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                localizations.errorLoadingUsers,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<UsersBloc>().add(const LoadUsersEvent());
                },
                icon: const Icon(Icons.refresh),
                label: Text(localizations.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.users.isEmpty) {
      final localizations = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                localizations.noUsersFound,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.selectedRole != null || state.selectedStatus != null
                    ? localizations.noUsersMatchFilters
                    : localizations.noUsersInSystem,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              if (state.selectedRole != null || state.selectedStatus != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<UsersBloc>().add(
                          const FilterUsersEvent(role: null, status: null),
                        );
                  },
                  icon: const Icon(Icons.clear),
                  label: Text(localizations.clearFilters),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: state.users.length + (state.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.users.length) {
          // Load More button
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: state.isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () {
                        context.read<UsersBloc>().add(const LoadMoreUsersEvent());
                      },
                      icon: const Icon(Icons.expand_more),
                      label: Text(AppLocalizations.of(context)!.loadMore),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
            ),
          );
        }

        final user = state.users[index];
        final isUpdating = state.updatingIds.contains(user.id);

        return UserListItem(
          user: user,
          isUpdating: isUpdating,
          onApprove: user.status == UserStatus.pendingApproval
              ? () {
                  context.read<UsersBloc>().add(ApproveUserEvent(user.id));
                }
              : null,
          onReject: user.status == UserStatus.pendingApproval
              ? () => _showRejectDialog(context, user)
              : null,
          onSuspend: user.status == UserStatus.active
              ? () => _showSuspendDialog(context, user)
              : null,
          onActivate: user.status == UserStatus.suspended
              ? () {
                  context.read<UsersBloc>().add(ActivateUserEvent(user.id));
                }
              : null,
        );
      },
    );
  }
}
