import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';

class PaginatedUsers {
  final List<ManagedUser> users;
  final int currentPage;
  final int totalPages;
  final bool hasMorePages;
  final int total;

  PaginatedUsers({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.hasMorePages,
    required this.total,
  });
}

abstract class BaseUsersRepository {
  /// Get paginated list of users with optional filters
  Future<Either<Failure, PaginatedUsers>> getUsers({
    int page = 1,
    int perPage = 20,
    UserRole? role,
    UserStatus? status,
    String? search,
  });

  /// Get single user by ID
  Future<Either<Failure, ManagedUser>> getUserById(int id);

  /// Approve a pending user
  Future<Either<Failure, void>> approveUser(int userId);

  /// Reject a pending user with reason
  Future<Either<Failure, void>> rejectUser(int userId, String reason);

  /// Suspend an active user with reason
  Future<Either<Failure, void>> suspendUser(int userId, String reason);

  /// Activate a suspended user
  Future<Either<Failure, void>> activateUser(int userId);
}
