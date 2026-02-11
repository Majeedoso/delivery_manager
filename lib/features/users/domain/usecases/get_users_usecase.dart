import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';

class GetUsersUseCase {
  final BaseUsersRepository repository;

  GetUsersUseCase(this.repository);

  Future<Either<Failure, PaginatedUsers>> call({
    int page = 1,
    int perPage = 20,
    UserRole? role,
    UserStatus? status,
    String? search,
  }) async {
    return await repository.getUsers(
      page: page,
      perPage: perPage,
      role: role,
      status: status,
      search: search,
    );
  }
}
