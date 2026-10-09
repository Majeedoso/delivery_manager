import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';
import 'package:equatable/equatable.dart';

/// A payment from the platform to a restaurant ([restaurantId], its own id)
/// or a driver ([driverId], their user id).
class RecordPlatformPaymentParams extends Equatable {
  final int? restaurantId;
  final int? driverId;
  final double amount;
  final String? notes;

  const RecordPlatformPaymentParams({
    this.restaurantId,
    this.driverId,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [restaurantId, driverId, amount, notes];
}

/// The platform pays what it owes (decision 6 of manager_suite_report.md: no
/// such payment could be recorded, so what it owed only grew).
class RecordPlatformPaymentUseCase {
  final BaseBankRepository repository;

  RecordPlatformPaymentUseCase(this.repository);

  Future<Either<Failure, Transaction>> call(
    RecordPlatformPaymentParams params,
  ) => repository.recordPlatformPayment(
    restaurantId: params.restaurantId,
    driverId: params.driverId,
    amount: params.amount,
    notes: params.notes,
  );
}
