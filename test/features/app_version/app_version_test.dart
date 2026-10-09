import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/app_version/data/datasource/app_version_remote_data_source.dart';
import 'package:delivery_manager/features/app_version/data/repository/app_version_repository.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/domain/repository/base_app_version_repository.dart';
import 'package:delivery_manager/features/app_version/domain/usecases/check_app_version_usecase.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';
import '../../helpers/locator.dart';
import '../../helpers/usecases.dart';

class _MockRemote extends Mock implements BaseAppVersionRemoteDataSource {}

class _MockRepository extends Mock implements BaseAppVersionRepository {}

class _MockCheck extends Mock implements CheckAppVersionUseCase {}

/// The start-up version check: the server says which manager-app version
/// is the minimum; an older app must update, anything else starts.
void main() {
  const path = '/app/version';
  const versions = AppVersion(
    minimumVersion: '1.2.0',
    currentVersion: '1.3.0',
    updateUrlAndroid: 'https://example.dz/app.apk',
  );

  setUpAll(() => registerFallbackValue(const NoParameters()));

  group('the API', () {
    late FakeBackend backend;
    late AppVersionRemoteDataSource source;

    setUp(() {
      backend = FakeBackend();
      source = AppVersionRemoteDataSource(
        dio: testDio(backend),
        logger: silentLogger(),
      );
    });

    // M6: it asked for the restaurant app's: a forced update of that app
    // would have locked the managers out, with its APK to download
    test('asks for the manager app\'s versions', () async {
      backend.reply(
        'GET',
        path,
        body: ok({'minimum_version': '1.2.0', 'current_version': '1.3.0'}),
      );

      await source.checkAppVersion();

      final request = backend.last('GET', path);
      expect(request.query, {'app_type': 'manager'});
      expect(request.headers['X-App-Type'], 'manager');
    });

    test('reads the versions and the update links', () async {
      backend.reply(
        'GET',
        path,
        body: ok({
          'minimum_version': '1.2.0',
          'current_version': '1.3.0',
          'update_url_android': 'https://example.dz/app.apk',
          'update_url_ios': null,
        }),
      );

      expect(await source.checkAppVersion(), versions);
    });

    test('an answer without the envelope is read too', () async {
      backend.reply(
        'GET',
        path,
        body: {'minimum_version': '1.2.0', 'current_version': '1.3.0'},
      );

      expect((await source.checkAppVersion()).minimumVersion, '1.2.0');
    });

    test('an answer without versions is refused', () async {
      backend.reply('GET', path, body: ok({'minimum_version': '1.2.0'}));

      await expectLater(
        source.checkAppVersion(),
        throwsA(isA<ServerException>()),
      );
    });

    test('offline is a network error', () async {
      backend.fail('GET', path, DioExceptionType.connectionTimeout);

      await expectLater(
        source.checkAppVersion(),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'an HTML error page is a server error with a readable message',
      () async {
        backend.reply(
          'GET',
          path,
          status: 502,
          body: htmlErrorPage,
          contentType: 'text/html',
        );

        await expectLater(
          source.checkAppVersion(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Server error occurred (Status: 502)',
            ),
          ),
        );
      },
    );
  });

  test('the repository maps each failure', () async {
    final remote = _MockRemote();
    final repository = AppVersionRepository(remoteDataSource: remote);

    when(() => remote.checkAppVersion()).thenAnswer((_) async => versions);
    expect(
      await repository.checkAppVersion(),
      const Right<Failure, AppVersion>(versions),
    );

    when(
      () => remote.checkAppVersion(),
    ).thenThrow(const NetworkException(message: 'offline'));
    expect(
      (await repository.checkAppVersion()).fold((f) => f, (_) => null),
      const NetworkFailure('offline'),
    );

    when(
      () => remote.checkAppVersion(),
    ).thenThrow(const ServerException(message: 'down'));
    expect(
      (await repository.checkAppVersion()).fold((f) => f, (_) => null),
      const ServerFailure('down'),
    );
  });

  test('the use case passes through', () {
    final repository = _MockRepository();
    return expectPassThrough<AppVersion>(
      stub: (answer) => when(
        () => repository.checkAppVersion(),
      ).thenAnswer((_) async => answer),
      run: () => CheckAppVersionUseCase(repository)(const NoParameters()),
      value: versions,
      verifyForwarded: () =>
          verify(() => repository.checkAppVersion()).called(1),
    );
  });

  group('the bloc', () {
    late _MockCheck check;

    setUp(() {
      check = _MockCheck();
      PackageInfo.setMockInitialValues(
        appName: 'Delivery',
        packageName: 'website.sofistem.delivery_manager',
        version: '1.2.0',
        buildNumber: '7',
        buildSignature: '',
      );
    });

    Future<AppVersionBloc> checked() async {
      final bloc = AppVersionBloc(
        checkAppVersionUseCase: check,
        logger: silentLogger(),
      );
      bloc.add(const CheckAppVersionEvent());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return bloc;
    }

    test('the minimum version itself is enough', () async {
      when(() => check(any())).thenAnswer((_) async => const Right(versions));

      final bloc = await checked();

      expect(bloc.state.requestState, RequestState.loaded);
      expect(bloc.state.isVersionSupported, isTrue);
      expect(bloc.state.userCurrentVersion, '1.2.0');
      expect(bloc.state.appVersion, versions);
      await bloc.close();
    });

    test('an older app must update', () async {
      when(() => check(any())).thenAnswer(
        (_) async => const Right(
          AppVersion(minimumVersion: '1.2.1', currentVersion: '1.3.0'),
        ),
      );

      final bloc = await checked();

      expect(bloc.state.isVersionSupported, isFalse);
      await bloc.close();
    });

    test('offline, the app starts', () async {
      when(
        () => check(any()),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));

      final bloc = await checked();

      expect(bloc.state.isVersionSupported, isTrue);
      await bloc.close();
    });

    test('a server error lets the app start too', () async {
      when(
        () => check(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server Error')));

      final bloc = await checked();

      expect(
        bloc.state.isVersionSupported,
        isTrue,
        reason:
            'it blocked the app with no version to update to: the '
            'splash stopped for good',
      );
      expect(bloc.state.appVersion, isNull);
      await bloc.close();
    });
  });
}
