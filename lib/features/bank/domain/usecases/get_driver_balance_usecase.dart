import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class GetDriverBalanceUseCase {
  final BaseBankRepository repository;

  GetDriverBalanceUseCase(this.repository);

  Future<Either<Failure, DriverBalance>> call({
    String? from,
    String? to,
  }) async {
    return await repository.getDriverBalance(from: from, to: to);
  }
}
