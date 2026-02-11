import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';

class ApproveUserUseCase {
  final BaseUsersRepository repository;

  ApproveUserUseCase(this.repository);

  Future<Either<Failure, void>> call(int userId) async {
    return await repository.approveUser(userId);
  }
}
