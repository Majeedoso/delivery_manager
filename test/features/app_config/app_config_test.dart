import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/app_config/data/datasource/app_config_remote_data_source.dart';
import 'package:delivery_manager/features/app_config/data/repository/app_config_repository.dart';
import 'package:delivery_manager/features/app_config/domain/entities/contact_info.dart';
import 'package:delivery_manager/features/app_config/domain/entities/legal_urls.dart';
import 'package:delivery_manager/features/app_config/domain/repository/base_app_config_repository.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_contact_info_usecase.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_parameters.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/api_json.dart';
import '../../helpers/fake_backend.dart';
import '../../helpers/usecases.dart';

class _MockRepository extends Mock implements BaseAppConfigRepository {}

/// The app's settings from the backend: the legal pages (in the manager's
/// language) and the company's contact details, over the app's own Dio.
void main() {
  group('the API', () {
    late FakeBackend backend;
    late AppConfigRemoteDataSourceImpl source;

    setUp(() {
      backend = FakeBackend();
      source = AppConfigRemoteDataSourceImpl(dio: testDio(backend));
    });

    test('the legal pages, in a language', () async {
      backend.reply(
        'GET',
        '/app/legal-urls',
        body: ok({
          'privacy_policy_url': 'https://example.dz/privacy?lang=fr',
          'terms_of_service_url': 'https://example.dz/terms?lang=fr',
        }),
      );

      final urls = await source.getLegalUrls(languageCode: 'fr');

      expect(backend.last('GET', '/app/legal-urls').query, {'lang': 'fr'});
      expect(urls.privacyPolicyUrl, 'https://example.dz/privacy?lang=fr');
      expect(urls.termsOfServiceUrl, 'https://example.dz/terms?lang=fr');
    });

    test('the contact details', () async {
      backend.reply(
        'GET',
        '/app/contact-info',
        body: ok({
          'email': 'contact@example.dz',
          'phone': '021000000',
          'website': null,
        }),
      );

      final contact = await source.getContactInfo();

      expect(contact.email, 'contact@example.dz');
      expect(contact.phone, '021000000');
      expect(contact.website, isNull);
    });

    test('offline is a network error', () async {
      backend.fail(
        'GET',
        '/app/contact-info',
        DioExceptionType.connectionError,
      );

      await expectLater(
        source.getContactInfo(),
        throwsA(isA<NetworkException>()),
        reason: 'it used to arrive as "An unexpected error occurred"',
      );
    });

    test('the server\'s refusal keeps its message', () async {
      backend.reply(
        'GET',
        '/app/legal-urls',
        status: 500,
        body: failure('Settings unavailable'),
      );

      await expectLater(
        source.getLegalUrls(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Settings unavailable',
          ),
        ),
      );
    });

    test('an HTML error page gives a readable message', () async {
      backend.reply(
        'GET',
        '/app/legal-urls',
        status: 502,
        body: htmlErrorPage,
        contentType: 'text/html',
      );

      await expectLater(
        source.getLegalUrls(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Server error occurred',
          ),
        ),
      );
    });

    test('an answer without success is refused', () async {
      backend.reply(
        'GET',
        '/app/contact-info',
        body: {'success': false, 'message': 'Not configured'},
      );

      await expectLater(
        source.getContactInfo(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('the repository and use cases', () {
    late _MockRepository repository;

    setUp(() => repository = _MockRepository());

    test('legal pages pass through with the language', () {
      return expectPassThrough<LegalUrls>(
        stub: (answer) => when(
          () =>
              repository.getLegalUrls(languageCode: any(named: 'languageCode')),
        ).thenAnswer((_) async => answer),
        run: () => GetLegalUrlsUseCase(repository)(
          const GetLegalUrlsParameters(languageCode: 'ar'),
        ),
        value: const LegalUrls(privacyPolicyUrl: 'p', termsOfServiceUrl: 't'),
        verifyForwarded: () =>
            verify(() => repository.getLegalUrls(languageCode: 'ar')).called(1),
      );
    });

    test('contact details pass through', () {
      return expectPassThrough<ContactInfo>(
        stub: (answer) => when(
          () => repository.getContactInfo(),
        ).thenAnswer((_) async => answer),
        run: () => GetContactInfoUseCase(repository)(const NoParameters()),
        value: const ContactInfo(email: 'contact@example.dz'),
        verifyForwarded: () =>
            verify(() => repository.getContactInfo()).called(1),
      );
    });

    test('the repository maps each failure', () async {
      final remote = _MockRemote();
      final repo = AppConfigRepository(remoteDataSource: remote);

      when(
        () => remote.getContactInfo(),
      ).thenThrow(const NetworkException(message: 'offline'));
      expect(
        (await repo.getContactInfo()).fold((f) => f, (_) => null),
        const NetworkFailure('offline'),
      );

      when(
        () => remote.getLegalUrls(languageCode: any(named: 'languageCode')),
      ).thenThrow(const ServerException(message: 'down'));
      expect(
        (await repo.getLegalUrls()).fold((f) => f, (_) => null),
        const ServerFailure('down'),
      );

      when(() => remote.getContactInfo()).thenThrow(StateError('bad'));
      expect((await repo.getContactInfo()).isLeft(), isTrue);
    });
  });
}

class _MockRemote extends Mock implements BaseAppConfigRemoteDataSource {}
