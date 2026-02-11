import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';

class RejectUserUseCase {
  final BaseUsersRepository repository;

  RejectUserUseCase(this.repository);

  Future<Either<Failure, void>> call(int userId, String reason) async {
    if (reason.trim().isEmpty) {
      return Left(ServerFailure('Rejection reason is required'));
    }
    return await repository.rejectUser(userId, reason);
  }
}
