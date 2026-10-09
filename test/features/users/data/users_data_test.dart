import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/data/datasource/users_remote_data_source.dart';
import 'package:delivery_manager/features/users/data/models/user_management_model.dart';
import 'package:delivery_manager/features/users/data/repository/users_repository_impl.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/api_json.dart';
import '../../../helpers/fake_backend.dart';
import '../../../helpers/fakes.dart';
import '../../../helpers/locator.dart';

/// The accounts the manager approves, refuses, suspends and activates
/// again, as the server lists them (UserManagementController): every role
/// but the managers, 20 at a time, the newest first.
void main() {
  const listPath = '/manager/users';

  group('an account', () {
    test('reads what the list sends', () {
      final user = UserManagementModel.fromJson(
        managedUserJson(rejectionReason: 'Documents unreadable'),
      );

      expect(user.id, 12);
      expect(user.name, 'Yacine Bouzid');
      expect(user.email, 'yacine@example.dz');
      expect(user.phone, '0661234567');
      expect(user.role, UserRole.driver);
      expect(user.status, UserStatus.pendingApproval);
      expect(user.emailVerifiedAt, DateTime.utc(2026, 9, 29, 8));
      expect(user.rejectionReason, 'Documents unreadable');
      expect(user.createdAt, DateTime.utc(2026, 9, 29, 7, 55));
    });

    test('every role and every status the server writes', () {
      for (final (name, role) in [
        ('customer', UserRole.customer),
        ('driver', UserRole.driver),
        ('restaurant', UserRole.restaurant),
        ('operator', UserRole.operator),
      ]) {
        expect(
          UserManagementModel.fromJson(managedUserJson(role: name)).role,
          role,
        );
      }
      for (final (name, status) in [
        ('pending_approval', UserStatus.pendingApproval),
        ('active', UserStatus.active),
        ('suspended', UserStatus.suspended),
        ('rejected', UserStatus.rejected),
      ]) {
        final user = UserManagementModel.fromJson(
          managedUserJson(status: name),
        );
        expect(user.status, status);
        expect(user.status.value, name, reason: 'sent back as it came');
      }
    });

    test('an account without a phone (Google), its email not verified', () {
      final user = UserManagementModel.fromJson(
        managedUserJson(phone: null, emailVerifiedAt: null),
      );

      expect(user.phone, '');
      expect(user.emailVerifiedAt, isNull);
    });
  });

  group('the API', () {
    late FakeBackend backend;
    late MockTokenRepository tokens;
    late UsersRemoteDataSourceImpl source;

    setUp(() {
      backend = FakeBackend();
      tokens = MockTokenRepository();
      when(
        () => tokens.getToken(),
      ).thenAnswer((_) async => const Right('tok-1'));
      source = UsersRemoteDataSourceImpl(
        dio: testDio(backend),
        tokenRepository: tokens,
        logger: silentLogger(),
      );
    });

    test('asks for the first 20 accounts, with the stored token', () async {
      backend.reply('GET', listPath, body: usersPageJson([managedUserJson()]));

      await source.getUsers();

      final request = backend.last('GET', listPath);
      expect(request.query, {'page': 1, 'per_page': 20});
      expect(request.headers['Authorization'], 'Bearer tok-1');
    });

    test('reads the page and where it is in the list', () async {
      backend.reply(
        'GET',
        listPath,
        body: usersPageJson(
          [
            managedUserJson(),
            managedUserJson(
              id: 13,
              name: 'Pizzeria Le Phare',
              role: 'restaurant',
              status: 'active',
            ),
          ],
          lastPage: 3,
          total: 45,
        ),
      );

      final page = await source.getUsers();

      expect(page.users.map((u) => (u.id, u.role, u.status)), [
        (12, UserRole.driver, UserStatus.pendingApproval),
        (13, UserRole.restaurant, UserStatus.active),
      ]);
      expect(
        (page.currentPage, page.totalPages, page.hasMorePages, page.total),
        (1, 3, true, 45),
      );
    });

    test('the last page has nothing after it', () async {
      backend.reply(
        'GET',
        listPath,
        body: usersPageJson(
          [managedUserJson()],
          currentPage: 3,
          lastPage: 3,
          total: 41,
        ),
      );

      final page = await source.getUsers(page: 3);

      expect(backend.last('GET', listPath).query['page'], 3);
      expect((page.currentPage, page.hasMorePages), (3, false));
    });

    test(
      'filters by role, status and words, as the server reads them',
      () async {
        backend.reply('GET', listPath, body: usersPageJson([]));

        await source.getUsers(
          role: UserRole.restaurant,
          status: 'suspended',
          search: 'phare',
        );

        expect(backend.last('GET', listPath).query, {
          'page': 1,
          'per_page': 20,
          'role': 'restaurant',
          'status': 'suspended',
          'search': 'phare',
        });
      },
    );

    test('an empty search is not sent', () async {
      backend.reply('GET', listPath, body: usersPageJson([]));

      await source.getUsers(search: '');

      expect(backend.last('GET', listPath).query.keys, ['page', 'per_page']);
    });

    group('the decisions', () {
      test('an approval sends nothing but the account', () async {
        backend.reply(
          'POST',
          '/manager/users/12/approve',
          body: userDecisionJson(status: 'active'),
        );

        await source.approveUser(12);

        final request = backend.last('POST', '/manager/users/12/approve');
        expect(request.data, isNull);
        expect(request.headers['Authorization'], 'Bearer tok-1');
      });

      test('a refusal sends its reason', () async {
        backend.reply(
          'POST',
          '/manager/users/12/reject',
          body: userDecisionJson(
            status: 'rejected',
            rejectionReason: 'Documents unreadable',
            message: 'User rejected successfully',
          ),
        );

        await source.rejectUser(12, 'Documents unreadable');

        expect(backend.last('POST', '/manager/users/12/reject').data, {
          'reason': 'Documents unreadable',
        });
      });

      test('a suspension sends its reason', () async {
        backend.reply(
          'POST',
          '/manager/users/12/suspend',
          body: userDecisionJson(
            status: 'suspended',
            rejectionReason: 'Too many cancelled orders',
            message: 'User suspended successfully',
          ),
        );

        await source.suspendUser(12, 'Too many cancelled orders');

        expect(backend.last('POST', '/manager/users/12/suspend').data, {
          'reason': 'Too many cancelled orders',
        });
      });

      test('an activation sends nothing but the account', () async {
        backend.reply(
          'POST',
          '/manager/users/12/activate',
          body: userDecisionJson(
            status: 'active',
            message: 'User activated successfully',
          ),
        );

        await source.activateUser(12);

        expect(backend.last('POST', '/manager/users/12/activate').data, isNull);
      });

      test('a refusal by the server says its reason', () async {
        backend.reply(
          'POST',
          '/manager/users/12/approve',
          status: 400,
          body: failure('User is not pending approval'),
        );

        await expectLater(
          source.approveUser(12),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'User is not pending approval',
            ),
          ),
        );
      });

      test('an answer that says no, with a 200, says why too', () async {
        backend.reply(
          'POST',
          '/manager/users/12/suspend',
          body: failure('Cannot modify manager accounts'),
        );

        await expectLater(
          source.suspendUser(12, 'Too many cancelled orders'),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Cannot modify manager accounts',
            ),
          ),
          reason: 'it read "Unexpected error: Instance of \'ServerException\'"',
        );
      });
    });

    // M13: what reached the page was "Unexpected error: Instance of
    // 'ServerException'", or Dio's own text; now the server's reason, or that
    // the network failed, which the page says in the manager's language
    group('a failed request', () {
      test('offline: the network failed', () async {
        backend.fail('GET', listPath, DioExceptionType.connectionError);

        await expectLater(
          source.getUsers(),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Network connection error',
            ),
          ),
        );
      });

      test('too slow to send: a timeout, not Dio\'s text', () async {
        backend.fail(
          'POST',
          '/manager/users/12/reject',
          DioExceptionType.sendTimeout,
        );

        await expectLater(
          source.rejectUser(12, 'Documents unreadable'),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'Request timeout',
            ),
          ),
        );
      });

      test('a field the server refused is named', () async {
        backend.reply(
          'POST',
          '/manager/users/12/reject',
          status: 422,
          body: validationFailure({
            'reason': [
              'The reason field must not be greater than 500 characters.',
            ],
          }),
        );

        await expectLater(
          source.rejectUser(12, 'x' * 600),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'The reason field must not be greater than 500 characters.',
            ),
          ),
        );
      });

      test('an error page is a server error', () async {
        backend.reply('GET', listPath, status: 502, body: htmlErrorPage);

        await expectLater(
          source.getUsers(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Server error occurred',
            ),
          ),
        );
      });

      test('without a token, nothing is sent, and it says so', () async {
        when(
          () => tokens.getToken(),
        ).thenAnswer((_) async => const Right(null));

        await expectLater(
          source.activateUser(12),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'No authentication token found',
            ),
          ),
        );
        expect(backend.requests, isEmpty);
      });
    });
  });

  group('the repository', () {
    late MockUsersRemoteDataSource remote;
    late UsersRepositoryImpl repository;

    setUp(() {
      remote = MockUsersRemoteDataSource();
      repository = UsersRepositoryImpl(remoteDataSource: remote);
    });

    test('a page, with the status as the server writes it', () async {
      when(
        () => remote.getUsers(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          role: any(named: 'role'),
          status: any(named: 'status'),
          search: any(named: 'search'),
        ),
      ).thenAnswer(
        (_) async => UsersPage(
          users: [UserManagementModel.fromJson(managedUserJson())],
          currentPage: 2,
          totalPages: 3,
          hasMorePages: true,
          total: 45,
        ),
      );

      final result = await repository.getUsers(
        page: 2,
        role: UserRole.driver,
        status: UserStatus.pendingApproval,
        search: 'bouzid',
      );

      final page = result.getOrElse(() => throw 'no page');
      expect(page.users.single.id, 12);
      expect(
        (page.currentPage, page.totalPages, page.hasMorePages, page.total),
        (2, 3, true, 45),
      );
      verify(
        () => remote.getUsers(
          page: 2,
          perPage: 20,
          role: UserRole.driver,
          status: 'pending_approval',
          search: 'bouzid',
        ),
      ).called(1);
    });

    test('the server\'s reason, and the network, become failures', () async {
      when(() => remote.approveUser(12)).thenThrow(
        const ServerException(message: 'User is not pending approval'),
      );
      when(
        () => remote.activateUser(12),
      ).thenThrow(const NetworkException(message: 'Network connection error'));

      expect(
        await repository.approveUser(12),
        const Left<Failure, void>(
          ServerFailure('User is not pending approval'),
        ),
      );
      expect(
        await repository.activateUser(12),
        const Left<Failure, void>(NetworkFailure('Network connection error')),
      );
    });

    test('each decision is handed to the server as it was taken', () async {
      when(() => remote.approveUser(any())).thenAnswer((_) async {});
      when(() => remote.rejectUser(any(), any())).thenAnswer((_) async {});
      when(() => remote.suspendUser(any(), any())).thenAnswer((_) async {});
      when(() => remote.activateUser(any())).thenAnswer((_) async {});

      expect(
        await repository.approveUser(12),
        const Right<Failure, void>(null),
      );
      expect(
        await repository.rejectUser(12, 'Documents unreadable'),
        const Right<Failure, void>(null),
      );
      expect(
        await repository.suspendUser(13, 'Too many cancelled orders'),
        const Right<Failure, void>(null),
      );
      expect(
        await repository.activateUser(13),
        const Right<Failure, void>(null),
      );

      verify(() => remote.approveUser(12)).called(1);
      verify(() => remote.rejectUser(12, 'Documents unreadable')).called(1);
      verify(
        () => remote.suspendUser(13, 'Too many cancelled orders'),
      ).called(1);
      verify(() => remote.activateUser(13)).called(1);
    });
  });
}
