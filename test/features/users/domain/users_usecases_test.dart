import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';
import 'package:delivery_manager/features/users/domain/usecases/activate_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/approve_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/get_users_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/reject_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/suspend_user_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/usecases.dart';

/// One use case per decision the manager takes on an account; a refusal and
/// a suspension need their reason, which the account's owner reads.
void main() {
  late MockUsersRepository repository;

  setUp(() => repository = MockUsersRepository());

  test('the list is asked for with its page, filters and words', () async {
    final page = PaginatedUsers(
      users: const [],
      currentPage: 2,
      totalPages: 2,
      hasMorePages: false,
      total: 21,
    );

    await expectPassThrough<PaginatedUsers>(
      stub: (answer) => when(
        () => repository.getUsers(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          role: any(named: 'role'),
          status: any(named: 'status'),
          search: any(named: 'search'),
        ),
      ).thenAnswer((_) async => answer),
      run: () => GetUsersUseCase(repository)(
        page: 2,
        role: UserRole.operator,
        status: UserStatus.suspended,
        search: 'nadia',
      ),
      value: page,
      verifyForwarded: () => verify(
        () => repository.getUsers(
          page: 2,
          perPage: 20,
          role: UserRole.operator,
          status: UserStatus.suspended,
          search: 'nadia',
        ),
      ).called(1),
    );
  });

  test('an approval and an activation name the account', () async {
    await expectPassThrough<void>(
      stub: (answer) => when(
        () => repository.approveUser(any()),
      ).thenAnswer((_) async => answer),
      run: () => ApproveUserUseCase(repository)(12),
      value: null,
      verifyForwarded: () => verify(() => repository.approveUser(12)).called(1),
    );
    await expectPassThrough<void>(
      stub: (answer) => when(
        () => repository.activateUser(any()),
      ).thenAnswer((_) async => answer),
      run: () => ActivateUserUseCase(repository)(13),
      value: null,
      verifyForwarded: () =>
          verify(() => repository.activateUser(13)).called(1),
    );
  });

  test('a refusal and a suspension carry their reason', () async {
    await expectPassThrough<void>(
      stub: (answer) => when(
        () => repository.rejectUser(any(), any()),
      ).thenAnswer((_) async => answer),
      run: () => RejectUserUseCase(repository)(12, 'Documents unreadable'),
      value: null,
      verifyForwarded: () => verify(
        () => repository.rejectUser(12, 'Documents unreadable'),
      ).called(1),
    );
    await expectPassThrough<void>(
      stub: (answer) => when(
        () => repository.suspendUser(any(), any()),
      ).thenAnswer((_) async => answer),
      run: () => SuspendUserUseCase(repository)(13, 'Too many cancellations'),
      value: null,
      verifyForwarded: () => verify(
        () => repository.suspendUser(13, 'Too many cancellations'),
      ).called(1),
    );
  });

  test('without a reason, nothing reaches the server', () async {
    expect(
      await RejectUserUseCase(repository)(12, '   '),
      const Left<Failure, void>(ServerFailure('Rejection reason is required')),
    );
    expect(
      await SuspendUserUseCase(repository)(13, ''),
      const Left<Failure, void>(ServerFailure('Suspension reason is required')),
    );
    verifyZeroInteractions(repository);
  });
}
