import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/profile/data/models/confirm_email_change_response_model.dart';
import 'package:delivery_manager/features/profile/data/models/profile_model.dart';
import 'package:delivery_manager/features/profile/data/models/resend_email_change_otp_response_model.dart';
import 'package:delivery_manager/features/profile/data/models/send_delete_account_otp_response_model.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_email_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/confirm_email_change_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/send_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/verify_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/api_json.dart';
import '../../../../helpers/fakes.dart';
import '../../../../helpers/locator.dart';

class _MockGet extends Mock implements GetProfileUseCase {}

class _MockUpdate extends Mock implements UpdateProfileUseCase {}

class _MockChangePassword extends Mock implements ChangePasswordUseCase {}

class _MockChangeEmail extends Mock implements ChangeEmailUseCase {}

class _MockConfirmEmail extends Mock implements ConfirmEmailChangeUseCase {}

class _MockSendDeleteOtp extends Mock implements SendDeleteAccountOtpUseCase {}

class _MockVerifyDeleteOtp extends Mock
    implements VerifyDeleteAccountOtpUseCase {}

/// The profile screens' bloc: read and edit the profile, change the password
/// and the email, delete the account. After an email change, "remember me"
/// fills the login form with the new email.
void main() {
  late _MockGet getProfile;
  late _MockUpdate update;
  late _MockChangePassword changePassword;
  late _MockChangeEmail changeEmail;
  late _MockConfirmEmail confirmEmail;
  late _MockSendDeleteOtp sendDeleteOtp;
  late _MockVerifyDeleteOtp verifyDeleteOtp;
  late MockLoadCredentialsUseCase loadCredentials;
  late MockSaveCredentialsUseCase saveCredentials;

  final profile = ProfileModel.fromJson(profileJson());

  setUpAll(() {
    registerFallbackValue(const NoParameters());
    registerFallbackValue(UpdateProfileParameters());
    registerFallbackValue(
      ChangePasswordParameters(
        currentPassword: '',
        newPassword: '',
        newPasswordConfirmation: '',
      ),
    );
    registerFallbackValue(
      ChangeEmailParameters(newEmail: '', currentPassword: ''),
    );
    registerFallbackValue(
      const ConfirmEmailChangeParameters(newEmail: '', otp: ''),
    );
    registerFallbackValue(const VerifyDeleteAccountOtpParameters(otp: ''));
    registerFallbackValue(
      const SaveCredentialsParameters(
        email: '',
        password: '',
        rememberMe: false,
      ),
    );
  });

  setUp(() {
    getProfile = _MockGet();
    update = _MockUpdate();
    changePassword = _MockChangePassword();
    changeEmail = _MockChangeEmail();
    confirmEmail = _MockConfirmEmail();
    sendDeleteOtp = _MockSendDeleteOtp();
    verifyDeleteOtp = _MockVerifyDeleteOtp();
    loadCredentials = MockLoadCredentialsUseCase();
    saveCredentials = MockSaveCredentialsUseCase();

    when(() => getProfile(any())).thenAnswer((_) async => Right(profile));
    when(() => update(any())).thenAnswer((_) async => Right(profile));
    when(
      () => changePassword(any()),
    ).thenAnswer((_) async => const Right(null));
    when(() => changeEmail(any())).thenAnswer(
      (_) async => const Right(
        ResendEmailChangeOtpResponseModel(
          newEmail: 'new@example.dz',
          expiresIn: 600,
          resendCountdown: 90,
        ),
      ),
    );
    when(() => confirmEmail(any())).thenAnswer(
      (_) async => Right(
        ConfirmEmailChangeResponseModel(
          profile: profile,
          message: 'تم تغيير البريد الإلكتروني',
        ),
      ),
    );
    when(() => sendDeleteOtp(any())).thenAnswer(
      (_) async => const Right(
        SendDeleteAccountOtpResponseModel(
          email: 'karim@example.dz',
          expiresIn: 600,
          resendCountdown: 60,
        ),
      ),
    );
    when(
      () => verifyDeleteOtp(any()),
    ).thenAnswer((_) async => const Right(null));
    // What "remember me" stores: the email, never the password
    when(() => loadCredentials(any())).thenAnswer(
      (_) async =>
          const Right({'email': 'karim@example.dz', 'rememberMe': 'true'}),
    );
    when(
      () => saveCredentials(any()),
    ).thenAnswer((_) async => const Right(true));
  });

  ProfileBloc build() => ProfileBloc(
    getProfileUseCase: getProfile,
    updateProfileUseCase: update,
    changePasswordUseCase: changePassword,
    changeEmailUseCase: changeEmail,
    confirmEmailChangeUseCase: confirmEmail,
    sendDeleteAccountOtpUseCase: sendDeleteOtp,
    verifyDeleteAccountOtpUseCase: verifyDeleteOtp,
    loadCredentialsUseCase: loadCredentials,
    saveCredentialsUseCase: saveCredentials,
    logger: silentLogger(),
  );

  Future<List<ProfileState>> run(ProfileEvent event) async {
    final bloc = build();
    final states = <ProfileState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await subscription.cancel();
    await bloc.close();
    return states;
  }

  test('reads the profile', () async {
    final states = await run(const GetProfileEvent());

    expect(states.map((s) => s.requestState), [
      RequestState.loading,
      RequestState.loaded,
    ]);
    expect(states.last.profile, profile);
  });

  test('a failed read says why', () async {
    when(
      () => getProfile(any()),
    ).thenAnswer((_) async => const Left(NetworkFailure('offline')));

    final states = await run(const GetProfileEvent());

    expect(states.last.requestState, RequestState.error);
    expect(states.last.message, 'offline');
  });

  test('an edit sends the fields and keeps the saved profile', () async {
    final states = await run(
      const UpdateProfileEvent(name: 'Karim', phone: '0550'),
    );

    final sent =
        verify(() => update(captureAny())).captured.single
            as UpdateProfileParameters;
    expect((sent.name, sent.phone), ('Karim', '0550'));
    expect(states.last.requestState, RequestState.loaded);
    expect(states.last.message, isNotEmpty, reason: 'the screen waits for it');
    expect(states.last.profile, profile);
  });

  test('a refused edit says why', () async {
    when(() => update(any())).thenAnswer(
      (_) async => const Left(ValidationFailure('Birthday cannot be changed')),
    );

    final states = await run(const UpdateProfileEvent(name: 'A'));

    expect(states.last.requestState, RequestState.error);
    expect(states.last.message, 'Birthday cannot be changed');
  });

  group('the password', () {
    test('changed: done', () async {
      final states = await run(
        const ChangePasswordEvent(
          currentPassword: 'Old-pass1',
          newPassword: 'New-pass1!',
          newPasswordConfirmation: 'New-pass1!',
        ),
      );

      expect(states.last.requestState, RequestState.loaded);
      expect(states.last.message, isNotEmpty);
    });

    test('refused: says why', () async {
      when(() => changePassword(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Current password is incorrect')),
      );

      final states = await run(
        const ChangePasswordEvent(
          currentPassword: 'wrong',
          newPassword: 'New-pass1!',
          newPasswordConfirmation: 'New-pass1!',
        ),
      );

      expect(states.last.requestState, RequestState.error);
      expect(states.last.message, 'Current password is incorrect');
    });
  });

  group('the email', () {
    test('a change sends a code, with the time before another', () async {
      final states = await run(
        const ChangeEmailEvent(
          newEmail: 'new@example.dz',
          currentPassword: 'Old-pass1',
        ),
      );

      expect(states.last.requestState, RequestState.loaded);
      expect(states.last.resendCountdown, 90);
      expect(
        states.last.message,
        contains('Email change request submitted'),
        reason: 'the code screen waits for this text',
      );
    });

    test('confirmed: the screens are told in their own words', () async {
      final states = await run(
        const ConfirmEmailChangeEvent(
          newEmail: 'new@example.dz',
          otp: '123456',
        ),
      );

      expect(states.last.requestState, RequestState.loaded);
      expect(
        states.last.message,
        contains('Email changed successfully'),
        reason: 'the screen waited for the server\'s wording',
      );
    });

    test('confirmed: "remember me" now fills in the new email', () async {
      await run(
        const ConfirmEmailChangeEvent(
          newEmail: 'new@example.dz',
          otp: '123456',
        ),
      );

      final saved =
          verify(() => saveCredentials(captureAny())).captured.single
              as SaveCredentialsParameters;
      expect(
        (saved.email, saved.rememberMe),
        ('new@example.dz', true),
        reason:
            'the update waited for a saved password, which is never stored: '
            'the old email stayed on the login form',
      );
    });

    test('confirmed without "remember me": nothing is saved', () async {
      when(() => loadCredentials(any())).thenAnswer(
        (_) async => const Right({'email': null, 'rememberMe': null}),
      );

      await run(
        const ConfirmEmailChangeEvent(
          newEmail: 'new@example.dz',
          otp: '123456',
        ),
      );

      verifyNever(() => saveCredentials(any()));
    });

    test('a wrong code: nothing is saved', () async {
      when(() => confirmEmail(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Invalid or expired OTP')),
      );

      final states = await run(
        const ConfirmEmailChangeEvent(
          newEmail: 'new@example.dz',
          otp: '000000',
        ),
      );

      expect(states.last.requestState, RequestState.error);
      verifyNever(() => saveCredentials(any()));
    });

    test(
      'the saved email failing to update doesn\'t undo the change',
      () async {
        when(() => loadCredentials(any())).thenThrow(StateError('keystore'));

        final states = await run(
          const ConfirmEmailChangeEvent(
            newEmail: 'new@example.dz',
            otp: '123456',
          ),
        );

        expect(states.last.requestState, RequestState.loaded);
      },
    );
  });

  group('deleting the account', () {
    test('a code is sent, with the time before another', () async {
      final states = await run(const SendDeleteAccountOtpEvent());

      expect(states.last.resendCountdown, 60);
      expect(states.last.message, contains('Account deletion OTP sent'));
    });

    test('the right code deletes it', () async {
      final states = await run(
        const VerifyDeleteAccountOtpEvent(otp: '654321'),
      );

      final sent =
          verify(() => verifyDeleteOtp(captureAny())).captured.single
              as VerifyDeleteAccountOtpParameters;
      expect(sent.otp, '654321');
      expect(states.last.message, contains('Account deleted successfully'));
    });

    test('a wrong code keeps it', () async {
      when(() => verifyDeleteOtp(any())).thenAnswer(
        (_) async => const Left(ValidationFailure('Invalid or expired OTP')),
      );

      final states = await run(const VerifyDeleteAccountOtpEvent(otp: '0'));

      expect(states.last.requestState, RequestState.error);
      expect(states.last.message, 'Invalid or expired OTP');
    });
  });
}
