import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

/// Most use cases only hand their parameters to one repository method. For
/// those, two things matter: the repository gets exactly what the caller
/// gave, and its answer comes back untouched, success or failure.
///
/// [stub] makes the repository method answer with the given result;
/// [verifyForwarded] checks it was called with the right arguments.
Future<void> expectPassThrough<T>({
  required void Function(Either<Failure, T> answer) stub,
  required Future<Either<Failure, T>> Function() run,
  required T value,
  required void Function() verifyForwarded,
}) async {
  stub(Right(value));
  expect(
    await run(),
    Right<Failure, T>(value),
    reason: 'success passes through',
  );
  verifyForwarded();

  const failure = ServerFailure('The backend said no');
  stub(const Left(failure));
  expect(
    await run(),
    Left<Failure, T>(failure),
    reason: 'failure passes through',
  );
}
