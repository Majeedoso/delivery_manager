import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/dashboard/data/datasource/dashboard_remote_data_source.dart';
import 'package:delivery_manager/features/dashboard/data/models/app_dashboard_model.dart';
import 'package:delivery_manager/features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_event.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';
import '../../helpers/fakes.dart';
import '../../helpers/locator.dart';

/// The platform settings the manager tunes (SettingsController): read by
/// group, 50 a page, and each changed by its id.
void main() {
  const path = '/manager/settings';

  final fee = AppDashboardModel.fromJson(settingJson());
  final email = AppDashboardModel.fromJson(
    settingJson(
      id: 2,
      key: 'contact_email',
      value: 'support@example.dz',
      typedValue: 'support@example.dz',
      type: 'string',
      category: 'legal_contact',
      description: 'Contact email address for customer support',
    ),
  );

  test('a setting reads what the server sends', () {
    expect(fee.id, 1);
    expect(fee.key, 'fixed_delivery_fee');
    expect((fee.value, fee.typedValue), ('150', 150.0));
    expect((fee.type, fee.category), ('decimal', 'delivery'));
    expect(fee.description, 'Fixed delivery fee in DZD');
    expect(fee.isPublic, isTrue);
  });

  group('the API', () {
    late FakeBackend backend;
    late DashboardRemoteDataSource source;

    setUp(() {
      backend = FakeBackend();
      source = DashboardRemoteDataSource(
        dio: testDio(backend),
        logger: silentLogger(),
      );
    });

    test('a group\'s settings, 50 a page, by group', () async {
      backend.reply(
        'GET',
        path,
        body: settingsPageJson([settingJson()], lastPage: 2, total: 51),
      );

      final page = await source.getSettings(category: 'delivery');

      expect(backend.last('GET', path).query, {
        'page': 1,
        'per_page': 50,
        'sort_by': 'category',
        'sort_order': 'asc',
        'category': 'delivery',
      });
      expect(
        (page['settings'] as List<AppDashboardModel>).single.key,
        'fixed_delivery_fee',
      );
      expect(
        (page['current_page'], page['last_page'], page['total']),
        (1, 2, 51),
      );
    });

    test('a change sends the new value', () async {
      backend.reply(
        'PUT',
        '$path/1',
        body: ok(settingJson(value: '200', typedValue: 200.0)),
      );

      final saved = await source.updateSetting(1, '200');

      expect(backend.last('PUT', '$path/1').json, {'value': '200'});
      expect(saved.value, '200');
    });

    test('a value refused says why', () async {
      backend.reply(
        'PUT',
        '$path/1',
        status: 422,
        body: validationError({
          'value': ['Value must be a valid number for type: decimal'],
        }),
      );

      await expectLater(
        source.updateSetting(1, 'abc'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Value must be a valid number for type: decimal',
          ),
        ),
      );
    });

    // An error page read as a map threw: "An unexpected error occurred..."
    test('an error page is a server error; offline, the network', () async {
      backend
        ..reply('GET', path, status: 500, body: htmlErrorPage)
        ..fail('PUT', '$path/1', DioExceptionType.connectionError);

      await expectLater(
        source.getSettings(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Server error occurred',
          ),
        ),
      );
      await expectLater(
        source.updateSetting(1, '200'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('the repository', () {
    late MockDashboardRemoteDataSource remote;
    late DashboardRepositoryImpl repository;

    setUp(() {
      remote = MockDashboardRemoteDataSource();
      repository = DashboardRepositoryImpl(remoteDataSource: remote);
    });

    test('passes a page and a saved setting through', () async {
      final page = {
        'settings': <AppDashboard>[fee],
        'current_page': 1,
        'last_page': 1,
        'total': 1,
      };
      when(
        () => remote.getSettings(
          category: any(named: 'category'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => page);
      when(() => remote.updateSetting(1, '200')).thenAnswer((_) async => fee);

      expect(
        await repository.getSettings(category: 'delivery', page: 2),
        Right<Failure, Map<String, dynamic>>(page),
      );
      expect(
        await repository.updateSetting(1, '200'),
        Right<Failure, AppDashboard>(fee),
      );
      verify(
        () => remote.getSettings(
          category: 'delivery',
          search: null,
          page: 2,
          perPage: 50,
        ),
      ).called(1);
    });

    test('failures keep their message', () async {
      when(
        () => remote.updateSetting(any(), any()),
      ).thenThrow(const ServerException(message: 'Setting not found.'));

      expect(
        await repository.updateSetting(9, '1'),
        const Left<Failure, AppDashboard>(ServerFailure('Setting not found.')),
      );
    });
  });

  group('the state', () {
    late MockDashboardRepository repository;

    Map<String, dynamic> page(
      List<AppDashboard> settings, {
      int current = 1,
      int last = 1,
    }) => {
      'settings': settings,
      'current_page': current,
      'last_page': last,
      'total': settings.length,
    };

    setUp(() => repository = MockDashboardRepository());

    DashboardBloc build() => DashboardBloc(repository: repository);

    blocTest<DashboardBloc, DashboardState>(
      'a group\'s settings',
      setUp: () => when(
        () => repository.getSettings(
          category: 'delivery',
          search: null,
          page: 1,
          perPage: 50,
        ),
      ).thenAnswer((_) async => Right(page([fee]))),
      build: build,
      act: (bloc) => bloc.add(const LoadSettingsEvent(category: 'delivery')),
      expect: () => [
        const DashboardState(settingsStatus: DashboardSettingsStatus.loading),
        DashboardState(
          settings: [fee],
          settingsStatus: DashboardSettingsStatus.loaded,
        ),
      ],
    );

    // M24: only the first 50 settings were read: the groups of the next ones
    // were missing from the dashboard
    blocTest<DashboardBloc, DashboardState>(
      'every page is read, one after the other',
      setUp: () {
        when(
          () => repository.getSettings(
            category: null,
            search: null,
            page: 1,
            perPage: 50,
          ),
        ).thenAnswer((_) async => Right(page([fee], last: 2)));
        when(
          () => repository.getSettings(
            category: null,
            search: null,
            page: 2,
            perPage: 50,
          ),
        ).thenAnswer((_) async => Right(page([email], current: 2, last: 2)));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => [
        const DashboardState(settingsStatus: DashboardSettingsStatus.loading),
        DashboardState(
          settings: [fee],
          settingsStatus: DashboardSettingsStatus.loaded,
          lastPage: 2,
        ),
        DashboardState(
          settings: [fee, email],
          settingsStatus: DashboardSettingsStatus.loaded,
          currentPage: 2,
          lastPage: 2,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'a failure says why',
      setUp: () =>
          when(
            () => repository.getSettings(
              category: any(named: 'category'),
              search: any(named: 'search'),
              page: any(named: 'page'),
              perPage: any(named: 'perPage'),
            ),
          ).thenAnswer(
            (_) async => const Left(NetworkFailure('Network connection error')),
          ),
      build: build,
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => [
        const DashboardState(settingsStatus: DashboardSettingsStatus.loading),
        const DashboardState(
          settingsStatus: DashboardSettingsStatus.error,
          errorMessage: 'Network connection error',
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'a change: the setting busy, then replaced',
      setUp: () => when(() => repository.updateSetting(1, '200')).thenAnswer(
        (_) async => Right(
          AppDashboardModel.fromJson(
            settingJson(value: '200', typedValue: 200.0),
          ),
        ),
      ),
      build: build,
      seed: () => DashboardState(
        settings: [fee, email],
        settingsStatus: DashboardSettingsStatus.loaded,
      ),
      act: (bloc) => bloc.add(const UpdateSettingEvent(id: 1, value: '200')),
      expect: () => [
        DashboardState(
          settings: [fee, email],
          settingsStatus: DashboardSettingsStatus.loaded,
          updateStatus: DashboardUpdateStatus.loading,
          updatingSettingId: 1,
        ),
        DashboardState(
          settings: [
            AppDashboardModel.fromJson(
              settingJson(value: '200', typedValue: 200.0),
            ),
            email,
          ],
          settingsStatus: DashboardSettingsStatus.loaded,
          updateStatus: DashboardUpdateStatus.success,
          updatedSettingId: 1,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'a refused change keeps the value, with the reason',
      setUp: () => when(() => repository.updateSetting(1, 'abc')).thenAnswer(
        (_) async => const Left(
          ServerFailure('Value must be a valid number for type: decimal'),
        ),
      ),
      build: build,
      seed: () => DashboardState(
        settings: [fee],
        settingsStatus: DashboardSettingsStatus.loaded,
      ),
      act: (bloc) => bloc.add(const UpdateSettingEvent(id: 1, value: 'abc')),
      expect: () => [
        DashboardState(
          settings: [fee],
          settingsStatus: DashboardSettingsStatus.loaded,
          updateStatus: DashboardUpdateStatus.loading,
          updatingSettingId: 1,
        ),
        DashboardState(
          settings: [fee],
          settingsStatus: DashboardSettingsStatus.loaded,
          updateStatus: DashboardUpdateStatus.error,
          updateErrorMessage: 'Value must be a valid number for type: decimal',
        ),
      ],
    );
  });
}
