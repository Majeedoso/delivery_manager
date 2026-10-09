import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/data/models/user_management_model.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_bloc.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_event.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';

/// The users page's state: the accounts page by page, the filters and the
/// search, and the four decisions (approve, refuse, suspend, activate), each
/// followed by a quiet refresh of the list.
void main() {
  late MockGetUsersUseCase getUsers;
  late MockApproveUserUseCase approve;
  late MockRejectUserUseCase reject;
  late MockSuspendUserUseCase suspend;
  late MockActivateUserUseCase activate;

  ManagedUser account(
    int id, {
    String role = 'driver',
    String status = 'pending_approval',
  }) => UserManagementModel.fromJson(
    managedUserJson(id: id, role: role, status: status),
  );

  final driver = account(12);
  final restaurant = account(13, role: 'restaurant', status: 'active');
  final operator = account(14, role: 'operator', status: 'suspended');

  PaginatedUsers page(
    List<ManagedUser> users, {
    int current = 1,
    int last = 1,
  }) => PaginatedUsers(
    users: users,
    currentPage: current,
    totalPages: last,
    hasMorePages: current < last,
    total: users.length,
  );

  /// Answers every request for the list with [answer].
  void listAnswers(Either<Failure, PaginatedUsers> answer) => when(
    () => getUsers(
      page: any(named: 'page'),
      perPage: any(named: 'perPage'),
      role: any(named: 'role'),
      status: any(named: 'status'),
      search: any(named: 'search'),
    ),
  ).thenAnswer((_) async => answer);

  /// Answers the list asked for with [role] with [answer].
  void answerFor(
    UserRole? role,
    Future<Either<Failure, PaginatedUsers>> Function() answer, {
    int pageNumber = 1,
  }) => when(
    () => getUsers(
      page: pageNumber,
      perPage: 20,
      role: role,
      status: any(named: 'status'),
      search: any(named: 'search'),
    ),
  ).thenAnswer((_) => answer());

  UsersBloc build() => UsersBloc(
    getUsersUseCase: getUsers,
    approveUserUseCase: approve,
    rejectUserUseCase: reject,
    suspendUserUseCase: suspend,
    activateUserUseCase: activate,
    logger: silentLogger(),
  );

  Matcher state({
    RequestState? requestState,
    List<int>? ids,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
    Set<int>? updatingIds,
    String? errorMessage,
    Object? action = const _Unset(),
    Object? role = const _Unset(),
    Object? status = const _Unset(),
    String? searchQuery,
  }) {
    var matcher = isA<UsersState>();
    if (requestState != null) {
      matcher = matcher.having(
        (s) => s.requestState,
        'requestState',
        requestState,
      );
    }
    if (ids != null) {
      matcher = matcher.having((s) => s.users.map((u) => u.id), 'ids', ids);
    }
    if (currentPage != null) {
      matcher = matcher.having(
        (s) => s.currentPage,
        'currentPage',
        currentPage,
      );
    }
    if (hasMorePages != null) {
      matcher = matcher.having(
        (s) => s.hasMorePages,
        'hasMorePages',
        hasMorePages,
      );
    }
    if (isLoadingMore != null) {
      matcher = matcher.having(
        (s) => s.isLoadingMore,
        'isLoadingMore',
        isLoadingMore,
      );
    }
    if (updatingIds != null) {
      matcher = matcher.having(
        (s) => s.updatingIds,
        'updatingIds',
        updatingIds,
      );
    }
    if (errorMessage != null) {
      matcher = matcher.having(
        (s) => s.errorMessage,
        'errorMessage',
        errorMessage,
      );
    }
    if (action is! _Unset) {
      matcher = matcher.having((s) => s.action, 'action', action);
    }
    if (role is! _Unset) {
      matcher = matcher.having((s) => s.selectedRole, 'selectedRole', role);
    }
    if (status is! _Unset) {
      matcher = matcher.having(
        (s) => s.selectedStatus,
        'selectedStatus',
        status,
      );
    }
    if (searchQuery != null) {
      matcher = matcher.having(
        (s) => s.searchQuery,
        'searchQuery',
        searchQuery,
      );
    }
    return matcher;
  }

  UsersState loaded(
    List<ManagedUser> users, {
    bool hasMorePages = false,
    UserRole? role,
    UserStatus? status,
    String search = '',
    Set<int> updatingIds = const {},
  }) => UsersState(
    requestState: RequestState.loaded,
    users: users,
    hasMorePages: hasMorePages,
    selectedRole: role,
    selectedStatus: status,
    searchQuery: search,
    updatingIds: updatingIds,
  );

  /// Lets the bloc's queued work run (events, awaited answers).
  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  setUp(() {
    getUsers = MockGetUsersUseCase();
    approve = MockApproveUserUseCase();
    reject = MockRejectUserUseCase();
    suspend = MockSuspendUserUseCase();
    activate = MockActivateUserUseCase();
  });

  test('starts by loading', () {
    expect(build().state, state(requestState: RequestState.loading, ids: []));
  });

  group('the list', () {
    blocTest<UsersBloc, UsersState>(
      'a load shows the spinner, then the first page',
      setUp: () => listAnswers(Right(page([driver, restaurant], last: 3))),
      build: build,
      act: (bloc) => bloc.add(const LoadUsersEvent()),
      expect: () => [
        state(requestState: RequestState.loading),
        state(
          requestState: RequestState.loaded,
          ids: [12, 13],
          currentPage: 1,
          hasMorePages: true,
        ),
      ],
      verify: (_) => verify(
        () => getUsers(
          page: 1,
          perPage: 20,
          role: null,
          status: null,
          search: null,
        ),
      ).called(1),
    );

    blocTest<UsersBloc, UsersState>(
      'a quiet refresh keeps the list on screen until the answer',
      setUp: () => listAnswers(Right(page([restaurant]))),
      build: build,
      seed: () => loaded([driver, restaurant]),
      act: (bloc) => bloc.add(const LoadUsersEvent(showLoading: false)),
      expect: () => [
        state(requestState: RequestState.loaded, ids: [13]),
      ],
    );

    blocTest<UsersBloc, UsersState>(
      'a failed load says why',
      setUp: () =>
          listAnswers(const Left(NetworkFailure('Network connection error'))),
      build: build,
      act: (bloc) => bloc.add(const LoadUsersEvent()),
      expect: () => [
        state(requestState: RequestState.loading),
        state(
          requestState: RequestState.error,
          errorMessage: 'Network connection error',
        ),
      ],
    );

    blocTest<UsersBloc, UsersState>(
      'the next page is added below, with the filters of the list',
      setUp: () => listAnswers(Right(page([operator], current: 2, last: 2))),
      build: build,
      seed: () => loaded(
        [driver, restaurant],
        hasMorePages: true,
        role: UserRole.driver,
        search: 'bou',
      ),
      act: (bloc) => bloc.add(const LoadMoreUsersEvent()),
      expect: () => [
        state(isLoadingMore: true, ids: [12, 13]),
        state(
          isLoadingMore: false,
          ids: [12, 13, 14],
          currentPage: 2,
          hasMorePages: false,
        ),
      ],
      verify: (_) => verify(
        () => getUsers(
          page: 2,
          perPage: 20,
          role: UserRole.driver,
          status: null,
          search: 'bou',
        ),
      ).called(1),
    );

    blocTest<UsersBloc, UsersState>(
      'the last page asks for nothing more',
      build: build,
      seed: () => loaded([driver]),
      act: (bloc) => bloc.add(const LoadMoreUsersEvent()),
      expect: () => <UsersState>[],
      verify: (_) => verifyZeroInteractions(getUsers),
    );

    blocTest<UsersBloc, UsersState>(
      'a failed next page keeps the list, and says why',
      setUp: () =>
          listAnswers(const Left(NetworkFailure('Network connection error'))),
      build: build,
      seed: () => loaded([driver, restaurant], hasMorePages: true),
      act: (bloc) => bloc.add(const LoadMoreUsersEvent()),
      expect: () => [
        state(isLoadingMore: true),
        state(
          requestState: RequestState.loaded,
          isLoadingMore: false,
          ids: [12, 13],
          errorMessage: 'Network connection error',
        ),
      ],
    );
  });

  group('the filters and the search', () {
    blocTest<UsersBloc, UsersState>(
      'a filter asks again from the first page, with the words searched',
      setUp: () => listAnswers(Right(page([driver]))),
      build: build,
      seed: () => loaded([driver, restaurant], search: 'bou'),
      act: (bloc) => bloc.add(
        const FilterUsersEvent(
          role: UserRole.driver,
          status: UserStatus.pendingApproval,
        ),
      ),
      expect: () => [
        state(
          requestState: RequestState.loading,
          role: UserRole.driver,
          status: UserStatus.pendingApproval,
        ),
        state(requestState: RequestState.loaded, ids: [12]),
      ],
      verify: (_) => verify(
        () => getUsers(
          page: 1,
          perPage: 20,
          role: UserRole.driver,
          status: UserStatus.pendingApproval,
          search: 'bou',
        ),
      ).called(1),
    );

    blocTest<UsersBloc, UsersState>(
      'clearing the filters asks for everyone',
      setUp: () => listAnswers(Right(page([driver, restaurant]))),
      build: build,
      seed: () => loaded(
        [driver],
        role: UserRole.driver,
        status: UserStatus.pendingApproval,
      ),
      act: (bloc) => bloc.add(const FilterUsersEvent(role: null, status: null)),
      expect: () => [
        state(requestState: RequestState.loading, role: null, status: null),
        state(requestState: RequestState.loaded, ids: [12, 13]),
      ],
    );

    blocTest<UsersBloc, UsersState>(
      'a search keeps the filters',
      setUp: () => listAnswers(Right(page([restaurant]))),
      build: build,
      seed: () => loaded([restaurant], role: UserRole.restaurant),
      act: (bloc) => bloc.add(const SearchUsersEvent('phare')),
      expect: () => [
        state(requestState: RequestState.loading, searchQuery: 'phare'),
        state(
          requestState: RequestState.loaded,
          ids: [13],
          role: UserRole.restaurant,
        ),
      ],
      verify: (_) => verify(
        () => getUsers(
          page: 1,
          perPage: 20,
          role: UserRole.restaurant,
          status: null,
          search: 'phare',
        ),
      ).called(1),
    );

    blocTest<UsersBloc, UsersState>(
      'an emptied search asks for every account again',
      setUp: () => listAnswers(Right(page([driver, restaurant]))),
      build: build,
      seed: () => loaded([restaurant], search: 'phare'),
      act: (bloc) => bloc.add(const SearchUsersEvent('')),
      expect: () => [
        state(requestState: RequestState.loading, searchQuery: ''),
        state(requestState: RequestState.loaded, ids: [12, 13]),
      ],
      verify: (_) => verify(
        () => getUsers(
          page: 1,
          perPage: 20,
          role: null,
          status: null,
          search: null,
        ),
      ).called(1),
    );

    // M11: the answers came back in any order, and the last to arrive won
    test('a slow answer to an earlier filter does not replace the later '
        'one', () async {
      final drivers = Completer<Either<Failure, PaginatedUsers>>();
      answerFor(UserRole.driver, () => drivers.future);
      answerFor(UserRole.restaurant, () async => Right(page([restaurant])));
      final bloc = build();

      bloc.add(const FilterUsersEvent(role: UserRole.driver));
      await settle();
      bloc.add(const FilterUsersEvent(role: UserRole.restaurant));
      await settle();
      drivers.complete(Right(page([driver])));
      await settle();

      expect(
        bloc.state,
        state(
          requestState: RequestState.loaded,
          ids: [13],
          role: UserRole.restaurant,
        ),
        reason: 'the drivers were listed under "Restaurant"',
      );
      await bloc.close();
    });

    test('a slow answer to an earlier search does not replace the later '
        'one', () async {
      final firstWords = Completer<Either<Failure, PaginatedUsers>>();
      when(
        () => getUsers(
          page: 1,
          perPage: 20,
          role: null,
          status: null,
          search: 'ya',
        ),
      ).thenAnswer((_) => firstWords.future);
      when(
        () => getUsers(
          page: 1,
          perPage: 20,
          role: null,
          status: null,
          search: 'yacine',
        ),
      ).thenAnswer((_) async => Right(page([driver])));
      final bloc = build();

      bloc.add(const SearchUsersEvent('ya'));
      await settle();
      bloc.add(const SearchUsersEvent('yacine'));
      await settle();
      firstWords.complete(Right(page([driver, restaurant, operator])));
      await settle();

      expect(
        bloc.state,
        state(
          requestState: RequestState.loaded,
          ids: [12],
          searchQuery: 'yacine',
        ),
      );
      await bloc.close();
    });

    test('a page asked for before a new filter is not added to it', () async {
      final secondPage = Completer<Either<Failure, PaginatedUsers>>();
      answerFor(null, () => secondPage.future, pageNumber: 2);
      answerFor(UserRole.restaurant, () async => Right(page([restaurant])));
      final bloc = build()..emit(loaded([driver], hasMorePages: true));

      bloc.add(const LoadMoreUsersEvent());
      await settle();
      bloc.add(const FilterUsersEvent(role: UserRole.restaurant));
      await settle();
      secondPage.complete(Right(page([operator], current: 2, last: 2)));
      await settle();

      expect(
        bloc.state,
        state(
          requestState: RequestState.loaded,
          ids: [13],
          isLoadingMore: false,
          role: UserRole.restaurant,
        ),
        reason: 'the operator of the list before was added to the restaurants',
      );
      await bloc.close();
    });
  });

  group('the decisions', () {
    blocTest<UsersBloc, UsersState>(
      'an approval marks the account busy, says it is done, then refreshes '
      'the list quietly',
      setUp: () {
        when(() => approve(12)).thenAnswer((_) async => const Right(null));
        listAnswers(Right(page([account(12, status: 'active'), restaurant])));
      },
      build: build,
      seed: () => loaded([driver, restaurant]),
      act: (bloc) => bloc.add(const ApproveUserEvent(12)),
      expect: () => [
        state(updatingIds: {12}, action: null),
        state(updatingIds: {}, action: UsersAction.approved),
        state(requestState: RequestState.loaded, ids: [12, 13], action: null),
      ],
      verify: (bloc) {
        verify(() => approve(12)).called(1);
        expect(bloc.state.users.first.status, UserStatus.active);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'a second tap while the account is busy does nothing',
      build: build,
      seed: () => loaded([driver], updatingIds: {12}),
      act: (bloc) => bloc
        ..add(const ApproveUserEvent(12))
        ..add(const RejectUserEvent(12, 'Documents unreadable'))
        ..add(const SuspendUserEvent(12, 'Too many cancellations'))
        ..add(const ActivateUserEvent(12)),
      expect: () => <UsersState>[],
      verify: (_) {
        verifyZeroInteractions(approve);
        verifyZeroInteractions(reject);
        verifyZeroInteractions(suspend);
        verifyZeroInteractions(activate);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'a refused approval keeps the list, and says why',
      setUp: () => when(() => approve(12)).thenAnswer(
        (_) async => const Left(ServerFailure('User is not pending approval')),
      ),
      build: build,
      seed: () => loaded([driver, restaurant]),
      act: (bloc) => bloc.add(const ApproveUserEvent(12)),
      expect: () => [
        state(updatingIds: {12}),
        state(
          requestState: RequestState.loaded,
          updatingIds: {},
          ids: [12, 13],
          errorMessage: 'User is not pending approval',
          action: null,
        ),
      ],
      verify: (_) => verifyZeroInteractions(getUsers),
    );

    blocTest<UsersBloc, UsersState>(
      'a refusal carries its reason',
      setUp: () {
        when(
          () => reject(12, 'Documents unreadable'),
        ).thenAnswer((_) async => const Right(null));
        listAnswers(Right(page([restaurant])));
      },
      build: build,
      seed: () => loaded([driver, restaurant]),
      act: (bloc) =>
          bloc.add(const RejectUserEvent(12, 'Documents unreadable')),
      expect: () => [
        state(updatingIds: {12}),
        state(updatingIds: {}, action: UsersAction.rejected),
        state(ids: [13], action: null),
      ],
      verify: (_) => verify(() => reject(12, 'Documents unreadable')).called(1),
    );

    blocTest<UsersBloc, UsersState>(
      'a suspension carries its reason',
      setUp: () {
        when(
          () => suspend(13, 'Too many cancellations'),
        ).thenAnswer((_) async => const Right(null));
        listAnswers(
          Right(
            page([
              driver,
              account(13, role: 'restaurant', status: 'suspended'),
            ]),
          ),
        );
      },
      build: build,
      seed: () => loaded([driver, restaurant]),
      act: (bloc) =>
          bloc.add(const SuspendUserEvent(13, 'Too many cancellations')),
      expect: () => [
        state(updatingIds: {13}),
        state(updatingIds: {}, action: UsersAction.suspended),
        state(ids: [12, 13], action: null),
      ],
    );

    blocTest<UsersBloc, UsersState>(
      'an activation, and a failed one',
      setUp: () {
        when(() => activate(14)).thenAnswer((_) async => const Right(null));
        when(() => activate(15)).thenAnswer(
          (_) async => const Left(NetworkFailure('Network connection error')),
        );
        listAnswers(
          Right(page([account(14, role: 'operator', status: 'active')])),
        );
      },
      build: build,
      seed: () => loaded([operator]),
      act: (bloc) async {
        bloc.add(const ActivateUserEvent(14));
        await settle();
        bloc.add(const ActivateUserEvent(15));
      },
      expect: () => [
        state(updatingIds: {14}),
        state(updatingIds: {}, action: UsersAction.activated),
        state(ids: [14], action: null),
        state(updatingIds: {15}),
        state(updatingIds: {}, errorMessage: 'Network connection error'),
      ],
    );

    blocTest<UsersBloc, UsersState>(
      'once told, the message and the result are cleared',
      build: build,
      seed: () => UsersState(
        requestState: RequestState.loaded,
        users: [driver],
        errorMessage: 'User is not pending approval',
        action: UsersAction.approved,
      ),
      act: (bloc) => bloc.add(const ClearUsersFeedbackEvent()),
      expect: () => [
        state(errorMessage: '', action: null, ids: [12]),
      ],
    );
  });
}

/// A filter of [state] left out: anything goes.
class _Unset {
  const _Unset();
}
