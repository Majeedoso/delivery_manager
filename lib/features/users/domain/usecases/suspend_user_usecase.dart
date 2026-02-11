import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';

class SuspendUserUseCase {
  final BaseUsersRepository repository;

  SuspendUserUseCase(this.repository);

  Future<Either<Failure, void>> call(int userId, String reason) async {
    if (reason.trim().isEmpty) {
      return Left(ServerFailure('Suspension reason is required'));
    }
    return await repository.suspendUser(userId, reason);
  }
}
