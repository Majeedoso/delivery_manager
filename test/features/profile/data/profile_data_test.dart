import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:delivery_manager/features/profile/data/models/confirm_email_change_response_model.dart';
import 'package:delivery_manager/features/profile/data/models/profile_model.dart';
import 'package:delivery_manager/features/profile/data/models/resend_email_change_otp_response_model.dart';
import 'package:delivery_manager/features/profile/data/models/send_delete_account_otp_response_model.dart';
import 'package:delivery_manager/features/profile/data/repository/profile_repository.dart';
import 'package:delivery_manager/features/profile/domain/entities/profile.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_email_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/confirm_email_change_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/send_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/verify_delete_account_otp_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/api_json.dart';
import '../../../helpers/fake_backend.dart';
import '../../../helpers/fakes.dart';
import '../../../helpers/locator.dart';
import '../../../helpers/usecases.dart';

class _MockRemote extends Mock implements BaseProfileRemoteDataSource {}

class _MockRepository extends Mock implements BaseProfileRepository {}

/// The manager's profile on the server: read (it is the signed-in account)
/// and edited (through the manager's own route), the password and the email
/// changed (the email through a code), the account deleted (through a code
/// too).
void main() {
  final profile = ProfileModel.fromJson(profileJson());

  setUpAll(() => registerFallbackValue(profile));

  group('a profile', () {
    test('reads the account', () {
      expect(profile.id, 7);
      expect(profile.name, 'Karim Haddad');
      expect(profile.email, 'karim@example.dz');
      expect(profile.phone, '0550123456');
      expect(profile.role, 'manager');
      expect(profile.emailVerifiedAt, DateTime.utc(2026, 9, 1, 10));
      expect(profile.createdAt, DateTime.utc(2026, 9, 1, 9));
    });

    test('an account without a phone or a verified email yet', () {
      final bare = ProfileModel.fromJson({
        ...profileJson(),
        'phone': null,
        'email_verified_at': null,
      });

      expect(bare.phone, '');
      expect(bare.emailVerifiedAt, isNull);
    });

    test('the email change and account deletion answers', () {
      final sent = ResendEmailChangeOtpResponseModel.fromJson(
        ok({
          'new_email': 'new@example.dz',
          'expires_in': 600,
          'resend_countdown': 90,
        }),
      );
      expect((sent.newEmail, sent.resendCountdown), ('new@example.dz', 90));

      final deletion = SendDeleteAccountOtpResponseModel.fromJson(
        ok({'email': 'karim@example.dz'}),
      );
      expect(deletion.resendCountdown, 120, reason: 'the default');

      final changed = ConfirmEmailChangeResponseModel.fromJson(
        ok({
          'user_id': 7,
          'old_email': 'karim@example.dz',
          'new_email': 'new@example.dz',
          'email_verified_at': '2026-09-30T12:00:00.000000Z',
          'updated_at': '2026-09-30T12:00:00.000000Z',
        }),
      );
      expect(changed.profile.email, 'new@example.dz');
    });
  });

  group('the API', () {
    late FakeBackend backend;
    late MockTokenRepository tokens;
    late ProfileRemoteDataSource source;
    const accountPath = '/auth/user';
    const savePath = '/manager/profile';

    /// PUT /manager/profile's answer (ManagerController::updateProfile).
    Map<String, dynamic> savedJson({String name = 'Karim Haddad'}) => ok({
      'id': 7,
      'name': name,
      'email': 'karim@example.dz',
      'phone': '0550123456',
      'role': 'manager',
      'email_verified_at': '2026-09-01T10:00:00.000000Z',
      'created_at': '2026-09-01T09:00:00.000000Z',
      'updated_at': '2026-09-30T12:00:00.000000Z',
    }, message: 'Profile updated successfully');

    setUp(() {
      backend = FakeBackend();
      tokens = MockTokenRepository();
      when(
        () => tokens.getToken(),
      ).thenAnswer((_) async => const Right('tok-1'));
      source = ProfileRemoteDataSource(
        dio: testDio(backend),
        tokenRepository: tokens,
        logger: silentLogger(),
      );
    });

    test('reads the profile with the stored token', () async {
      backend.reply('GET', accountPath, body: ok(profileJson()));

      final read = await source.getProfile();

      expect(read.name, 'Karim Haddad');
      expect(
        backend.last('GET', accountPath).headers['Authorization'],
        'Bearer tok-1',
      );
    });

    test('without a token, says so', () async {
      when(() => tokens.getToken()).thenAnswer((_) async => const Right(null));

      await expectLater(
        source.getProfile(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'No authentication token found',
          ),
        ),
        reason: 'it read "Unexpected error: Instance of \'ServerException\'"',
      );
      expect(backend.requests, isEmpty);
    });

    test('an edit is saved through the manager\'s own route, sending only '
        'what changed', () async {
      backend.reply('PUT', savePath, body: savedJson(name: 'Karim H.'));
      backend.reply(
        'GET',
        accountPath,
        body: ok(profileJson(name: 'Karim H.')),
      );

      final saved = await source.updateProfile(name: 'Karim H.');

      expect(
        backend.last('PUT', savePath).json,
        {'name': 'Karim H.'},
        reason:
            'it sent user_name to PUT /auth/user, a route the server does not '
            'have: every edit failed (M8)',
      );
      expect(
        backend.last('PUT', savePath).headers['Authorization'],
        'Bearer tok-1',
      );
      expect(backend.count('PUT', accountPath), 0);
      expect(saved.name, 'Karim H.');
    });

    test('the saved profile is read again, as the account says it', () async {
      backend.reply('PUT', savePath, body: savedJson());
      backend.reply('GET', accountPath, body: ok(profileJson()));

      final saved = await source.updateProfile(phone: '0661000000');

      expect(backend.last('PUT', savePath).json, {'phone': '0661000000'});
      expect(backend.count('GET', accountPath), 1);
      expect(saved.role, 'manager');
      expect(saved.createdAt, DateTime.utc(2026, 9, 1, 9));
    });

    test('a refused field says which', () async {
      backend.reply(
        'PUT',
        savePath,
        status: 422,
        body: {
          'success': false,
          'message': 'Validation failed',
          'errors': {
            'phone': [
              'The phone field must not be greater than 20 characters.',
            ],
          },
        },
      );

      await expectLater(
        source.updateProfile(phone: '0' * 21),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'The phone field must not be greater than 20 characters.',
          ),
        ),
        reason: 'the reason was replaced by "Validation failed"',
      );
      expect(backend.count('GET', accountPath), 0);
    });

    test('changes the password', () async {
      backend.reply(
        'POST',
        '/auth/change-password',
        body: {'success': true, 'message': 'Password changed'},
      );

      await source.changePassword(
        currentPassword: 'Old-pass1',
        newPassword: 'New-pass1!',
        newPasswordConfirmation: 'New-pass1!',
      );

      expect(backend.last('POST', '/auth/change-password').json, {
        'current_password': 'Old-pass1',
        'new_password': 'New-pass1!',
        'new_password_confirmation': 'New-pass1!',
      });
    });

    test('a wrong current password keeps the server\'s reason', () async {
      backend.reply(
        'POST',
        '/auth/change-password',
        status: 400,
        body: failure('Current password is incorrect'),
      );

      await expectLater(
        source.changePassword(
          currentPassword: 'wrong',
          newPassword: 'New-pass1!',
          newPasswordConfirmation: 'New-pass1!',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Current password is incorrect',
          ),
        ),
      );
    });

    test('asks to change the email, then confirms it with the code', () async {
      backend.reply(
        'POST',
        '/auth/change-email',
        body: ok({'new_email': 'new@example.dz', 'resend_countdown': 60}),
      );
      backend.reply(
        'POST',
        '/auth/email/confirm-change',
        body: ok(
          {'user_id': 7, 'new_email': 'new@example.dz'},
          message:
              'Email changed successfully. Your new email has been verified.',
        ),
      );

      final sent = await source.changeEmail(
        newEmail: 'new@example.dz',
        currentPassword: 'Old-pass1',
      );
      final changed = await source.confirmEmailChange(
        newEmail: 'new@example.dz',
        otp: '123456',
      );

      expect(backend.last('POST', '/auth/change-email').json, {
        'new_email': 'new@example.dz',
        'current_password': 'Old-pass1',
      });
      expect(sent.resendCountdown, 60);
      expect(backend.last('POST', '/auth/email/confirm-change').json, {
        'new_email': 'new@example.dz',
        'otp': '123456',
      });
      expect(changed.profile.email, 'new@example.dz');
    });

    test('a wrong or expired code says so', () async {
      backend.reply(
        'POST',
        '/auth/email/confirm-change',
        status: 400,
        body: failure('Invalid or expired OTP. Please request a new one.'),
      );

      await expectLater(
        source.confirmEmailChange(newEmail: 'new@example.dz', otp: '000000'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Invalid or expired OTP. Please request a new one.',
          ),
        ),
      );
    });

    test('deleting the account: a code, then the code back', () async {
      backend.reply(
        'POST',
        '/auth/account/delete/send-otp',
        body: ok({'email': 'karim@example.dz', 'resend_countdown': 120}),
      );
      backend.reply(
        'POST',
        '/auth/account/delete/verify-otp',
        body: {'success': true, 'message': 'Account deleted successfully'},
      );

      final sent = await source.sendDeleteAccountOtp();
      await source.verifyDeleteAccountOtpAndDelete(otp: '654321');

      expect(sent.email, 'karim@example.dz');
      expect(backend.last('POST', '/auth/account/delete/verify-otp').json, {
        'otp': '654321',
      });
    });

    test('a wrong deletion code, and asking too often', () async {
      backend.reply(
        'POST',
        '/auth/account/delete/verify-otp',
        status: 400,
        body: failure('Invalid or expired OTP'),
      );
      await expectLater(
        source.verifyDeleteAccountOtpAndDelete(otp: '000000'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Invalid or expired OTP',
          ),
        ),
      );

      backend.reply(
        'POST',
        '/auth/account/delete/send-otp',
        status: 429,
        body: failure('Please wait 60 seconds'),
      );
      await expectLater(
        source.sendDeleteAccountOtp(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Please wait 60 seconds',
          ),
        ),
      );
    });

    test('signed out on the server: log in again', () async {
      backend.reply(
        'GET',
        accountPath,
        status: 401,
        body: {'message': 'Unauthenticated.'},
      );

      await expectLater(
        source.getProfile(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Authentication failed. Please login again.',
          ),
        ),
      );
    });

    test('a refusal never speaks of operators', () async {
      backend.reply(
        'GET',
        accountPath,
        status: 403,
        body: failure('Your account has been suspended.'),
      );

      await expectLater(
        source.getProfile(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Your account has been suspended.',
          ),
        ),
        reason: 'it said "Only operators can view their profile."',
      );
    });

    test('an HTML error page is a server error, not a TypeError', () async {
      for (final (method, endpoint, call)
          in <(String, String, Future<Object?> Function())>[
            ('GET', accountPath, () => source.getProfile()),
            ('PUT', savePath, () => source.updateProfile(name: 'A')),
            (
              'POST',
              '/auth/change-email',
              () =>
                  source.changeEmail(newEmail: 'n@e.dz', currentPassword: 'p'),
            ),
            (
              'POST',
              '/auth/account/delete/verify-otp',
              () => source.verifyDeleteAccountOtpAndDelete(otp: '1'),
            ),
          ]) {
        backend.reply(
          method,
          endpoint,
          status: 502,
          body: htmlErrorPage,
          contentType: 'text/html',
        );

        await expectLater(
          call(),
          throwsA(isA<ServerException>()),
          reason: '$method $endpoint',
        );
      }
    });

    test('offline is a network error', () async {
      backend.fail('GET', accountPath, DioExceptionType.connectionError);
      await expectLater(source.getProfile(), throwsA(isA<NetworkException>()));

      backend.fail('PUT', savePath, DioExceptionType.connectionError);
      await expectLater(
        source.updateProfile(name: 'A'),
        throwsA(isA<NetworkException>()),
      );

      backend.fail(
        'POST',
        '/auth/change-password',
        DioExceptionType.receiveTimeout,
      );
      await expectLater(
        source.changePassword(
          currentPassword: 'a',
          newPassword: 'b',
          newPasswordConfirmation: 'b',
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('the repository', () {
    late _MockRemote remote;
    late ProfileRepository repository;

    setUp(() {
      remote = _MockRemote();
      repository = ProfileRepository(baseProfileRemoteDataSource: remote);
    });

    test('answers with the profile it read or saved', () async {
      when(() => remote.getProfile()).thenAnswer((_) async => profile);
      when(
        () => remote.updateProfile(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenAnswer((_) async => profile);

      expect(await repository.getProfile(), Right<Failure, Profile>(profile));
      expect(
        await repository.updateProfile(name: 'Karim'),
        Right<Failure, Profile>(profile),
      );
    });

    test('offline is a network failure, in every call', () async {
      const offline = NetworkException(message: 'offline');
      when(() => remote.getProfile()).thenThrow(offline);
      when(
        () => remote.updateProfile(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
        ),
      ).thenThrow(offline);
      when(
        () => remote.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirmation: any(named: 'newPasswordConfirmation'),
        ),
      ).thenThrow(offline);
      when(
        () => remote.changeEmail(
          newEmail: any(named: 'newEmail'),
          currentPassword: any(named: 'currentPassword'),
        ),
      ).thenThrow(offline);
      when(
        () => remote.confirmEmailChange(
          newEmail: any(named: 'newEmail'),
          otp: any(named: 'otp'),
        ),
      ).thenThrow(offline);
      when(() => remote.sendDeleteAccountOtp()).thenThrow(offline);
      when(
        () => remote.verifyDeleteAccountOtpAndDelete(otp: any(named: 'otp')),
      ).thenThrow(offline);

      for (final call in <Future<Either<Failure, Object?>> Function()>[
        () => repository.getProfile(),
        () => repository.updateProfile(name: 'A'),
        () => repository.changePassword(
          currentPassword: 'a',
          newPassword: 'b',
          newPasswordConfirmation: 'b',
        ),
        () => repository.changeEmail(newEmail: 'n@e.dz', currentPassword: 'p'),
        () => repository.confirmEmailChange(newEmail: 'n@e.dz', otp: '1'),
        () => repository.sendDeleteAccountOtp(),
        () => repository.verifyDeleteAccountOtpAndDelete(otp: '1'),
      ]) {
        expect(
          (await call()).fold((f) => f, (_) => null),
          const NetworkFailure('offline'),
          reason: 'four of the seven let the exception escape',
        );
      }
    });

    test('refusals keep their kind', () async {
      when(
        () => remote.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirmation: any(named: 'newPasswordConfirmation'),
        ),
      ).thenThrow(const ValidationException(message: 'too short'));
      when(
        () => remote.changeEmail(
          newEmail: any(named: 'newEmail'),
          currentPassword: any(named: 'currentPassword'),
        ),
      ).thenThrow(const ServerException(message: 'wrong password'));
      when(() => remote.getProfile()).thenThrow(StateError('bad'));

      expect(
        (await repository.changePassword(
          currentPassword: 'a',
          newPassword: 'b',
          newPasswordConfirmation: 'b',
        )).fold((f) => f, (_) => null),
        const ValidationFailure('too short'),
      );
      expect(
        (await repository.changeEmail(
          newEmail: 'n@e.dz',
          currentPassword: 'p',
        )).fold((f) => f, (_) => null),
        const ServerFailure('wrong password'),
      );
      expect(
        (await repository.getProfile()).fold((f) => f, (_) => null),
        isA<ServerFailure>(),
        reason: 'never a throw',
      );
    });
  });

  group('the use cases', () {
    late _MockRepository repository;

    setUp(() => repository = _MockRepository());

    test('the profile passes through', () {
      return expectPassThrough<Profile>(
        stub: (answer) =>
            when(() => repository.getProfile()).thenAnswer((_) async => answer),
        run: () => GetProfileUseCase(repository)(const NoParameters()),
        value: profile,
        verifyForwarded: () => verify(() => repository.getProfile()).called(1),
      );
    });

    test('an edit passes its fields', () {
      return expectPassThrough<Profile>(
        stub: (answer) => when(
          () => repository.updateProfile(
            name: any(named: 'name'),
            phone: any(named: 'phone'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => UpdateProfileUseCase(repository)(
          UpdateProfileParameters(name: 'A', phone: '055'),
        ),
        value: profile,
        verifyForwarded: () => verify(
          () => repository.updateProfile(name: 'A', phone: '055'),
        ).called(1),
      );
    });

    test('a password change passes the three passwords', () async {
      when(
        () => repository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
          newPasswordConfirmation: any(named: 'newPasswordConfirmation'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await ChangePasswordUseCase(repository)(
        ChangePasswordParameters(
          currentPassword: 'a',
          newPassword: 'b',
          newPasswordConfirmation: 'c',
        ),
      );

      verify(
        () => repository.changePassword(
          currentPassword: 'a',
          newPassword: 'b',
          newPasswordConfirmation: 'c',
        ),
      ).called(1);
    });

    test('an email change passes the email and the password', () {
      return expectPassThrough(
        stub: (answer) => when(
          () => repository.changeEmail(
            newEmail: any(named: 'newEmail'),
            currentPassword: any(named: 'currentPassword'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => ChangeEmailUseCase(repository)(
          ChangeEmailParameters(newEmail: 'n@e.dz', currentPassword: 'p'),
        ),
        value: const ResendEmailChangeOtpResponseModel(
          newEmail: 'n@e.dz',
          expiresIn: 600,
          resendCountdown: 120,
        ),
        verifyForwarded: () => verify(
          () =>
              repository.changeEmail(newEmail: 'n@e.dz', currentPassword: 'p'),
        ).called(1),
      );
    });

    test('the confirmation passes the email and the code', () {
      return expectPassThrough(
        stub: (answer) => when(
          () => repository.confirmEmailChange(
            newEmail: any(named: 'newEmail'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => answer),
        run: () => ConfirmEmailChangeUseCase(repository)(
          const ConfirmEmailChangeParameters(newEmail: 'n@e.dz', otp: '123456'),
        ),
        value: ConfirmEmailChangeResponseModel(profile: profile, message: 'ok'),
        verifyForwarded: () => verify(
          () =>
              repository.confirmEmailChange(newEmail: 'n@e.dz', otp: '123456'),
        ).called(1),
      );
    });

    test('the deletion code is asked for, then sent back', () async {
      when(() => repository.sendDeleteAccountOtp()).thenAnswer(
        (_) async => const Right(
          SendDeleteAccountOtpResponseModel(
            email: 'a@e.dz',
            expiresIn: 600,
            resendCountdown: 120,
          ),
        ),
      );
      when(
        () =>
            repository.verifyDeleteAccountOtpAndDelete(otp: any(named: 'otp')),
      ).thenAnswer((_) async => const Right(null));

      await SendDeleteAccountOtpUseCase(repository)(const NoParameters());
      await VerifyDeleteAccountOtpUseCase(repository)(
        const VerifyDeleteAccountOtpParameters(otp: '654321'),
      );

      verify(() => repository.sendDeleteAccountOtp()).called(1);
      verify(
        () => repository.verifyDeleteAccountOtpAndDelete(otp: '654321'),
      ).called(1);
    });
  });
}
