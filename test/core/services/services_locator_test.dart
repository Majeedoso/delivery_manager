import 'dart:io';

import 'package:delivery_manager/features/delivery_areas/data/datasource/delivery_areas_remote_data_source.dart';
import 'package:delivery_manager/features/delivery_areas/domain/repository/base_delivery_areas_repository.dart';
import 'package:delivery_manager/features/delivery_areas/domain/usecases/delivery_areas_usecases.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_bloc.dart';
import 'package:delivery_manager/core/services/device_info_service.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/public_settings_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/app_config/data/datasource/app_config_remote_data_source.dart';
import 'package:delivery_manager/features/app_config/domain/repository/base_app_config_repository.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_contact_info_usecase.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_usecase.dart';
import 'package:delivery_manager/features/app_version/data/datasource/app_version_remote_data_source.dart';
import 'package:delivery_manager/features/app_version/domain/repository/base_app_version_repository.dart';
import 'package:delivery_manager/features/app_version/domain/usecases/check_app_version_usecase.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/google_auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/secure_storage_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_remote_data_source.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_secure_storage_repository.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/clear_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/clear_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/get_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/google_sign_out_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/reset_password_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/send_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/validate_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_bloc.dart';
import 'package:delivery_manager/features/bank/data/datasource/bank_remote_data_source.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';
import 'package:delivery_manager/features/bank/domain/usecases/answer_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_platform_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/get_driver_balance_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/get_transactions_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_restaurant_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_system_payment_usecase.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/coupons/data/datasource/coupons_remote_data_source.dart';
import 'package:delivery_manager/features/coupons/domain/repository/base_coupons_repository.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/dashboard/data/datasource/dashboard_remote_data_source.dart';
import 'package:delivery_manager/features/dashboard/domain/repository/base_dashboard_repository.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:delivery_manager/features/localization/data/datasource/localization_local_data_source.dart';
import 'package:delivery_manager/features/localization/domain/repository/base_localization_repository.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_email_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/confirm_email_change_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/send_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:delivery_manager/features/profile/domain/usecases/verify_delete_account_otp_usecase.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/users/data/datasource/users_remote_data_source.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';
import 'package:delivery_manager/features/users/domain/usecases/activate_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/approve_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/get_users_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/reject_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/suspend_user_usecase.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

/// ServicesLocator().init() wires the whole app together. A missing or broken
/// registration only shows at runtime, on the screen that needs it, so these
/// tests resolve every registration and scan lib/ for lookups of types that
/// were never registered.
void main() {
  setUp(() async {
    await ServicesLocator().init();
    await useFakeGoogleSignIn();
  });

  test('every registration resolves', () async {
    for (final registration in registrations.entries) {
      final Object instance;
      try {
        instance = registration.value();
      } catch (error) {
        fail('${registration.key} does not resolve: $error');
      }
      if (instance is BlocBase) await instance.close();
    }
  });

  test('every sl lookup in lib/ names a registered type', () {
    final lookup = RegExp(r'(?:\bsl|GetIt\.instance)(?:\.get)?<(\w+)>\s*\(');
    final unregistered = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      for (final match in lookup.allMatches(file.readAsStringSync())) {
        final type = match.group(1)!;
        if (type.length == 1) continue; // a type parameter such as T
        if (!registrations.containsKey(type)) {
          unregistered.add('$type in ${file.path}');
        }
      }
    }

    expect(
      unregistered,
      isEmpty,
      reason: 'the app would throw when it reaches these lookups',
    );
  });

  test('blocs are new on every lookup; services are shared', () async {
    final first = sl<AuthBloc>();
    final second = sl<AuthBloc>();

    expect(
      identical(first, second),
      isFalse,
      reason: 'each screen owns its bloc',
    );
    expect(identical(sl<Dio>(), sl<Dio>()), isTrue);
    expect(
      identical(sl<BaseTokenRepository>(), sl<BaseTokenRepository>()),
      isTrue,
      reason: 'every request reads the one stored token',
    );

    await first.close();
    await second.close();
  });

  test('init starts from an empty locator', () async {
    final earlier = LoggingService();
    await sl.unregister<LoggingService>();
    sl.registerSingleton<LoggingService>(earlier);

    await ServicesLocator().init();

    expect(
      identical(sl<LoggingService>(), earlier),
      isFalse,
      reason:
          'fakes registered before init are dropped, so tests use the '
          'locator helpers instead of init',
    );
  });

  test('init removes the plain copy of the token an earlier version '
      'left', () async {
    SharedPreferences.setMockInitialValues({'auth_token': '1|abcdef'});

    await ServicesLocator().init();
    await useFakeGoogleSignIn();

    expect(sl<SharedPreferences>().getString('auth_token'), isNull);
  });

  test('init can run twice (the retry on the startup error screen)', () async {
    await ServicesLocator().init();
    await useFakeGoogleSignIn();

    expect(sl<BaseAuthRepository>(), isNotNull);
    expect(sl<Dio>().options.baseUrl, 'http://test.local/api');
  });
}

/// FirebaseAuth.instance needs an initialized Firebase app. Only the Google
/// sign-in data source uses it (and GoogleSignIn), so both become mocks.
Future<void> useFakeGoogleSignIn() async {
  await sl.unregister<FirebaseAuth>();
  sl.registerLazySingleton<FirebaseAuth>(MockFirebaseAuth.new);
  await sl.unregister<GoogleSignIn>();
  sl.registerLazySingleton<GoogleSignIn>(MockGoogleSignIn.new);
}

MapEntry<String, Object Function()> _entry<T extends Object>() =>
    MapEntry('$T', () => sl<T>());

/// Everything init() registers, by type name.
final registrations = Map.fromEntries([
  _entry<Dio>(),
  _entry<FirebaseAuth>(),
  _entry<GoogleSignIn>(),
  _entry<SharedPreferences>(),
  _entry<LoggingService>(),
  _entry<PublicSettingsService>(),
  _entry<DeviceInfoService>(),
  _entry<BaseAuthRemoteDataSource>(),
  _entry<BaseAuthLocalDataSource>(),
  _entry<BaseGoogleAuthRemoteDataSource>(),
  _entry<BaseSecureStorageLocalDataSource>(),
  _entry<BaseTokenLocalDataSource>(),
  _entry<BaseTokenRemoteDataSource>(),
  _entry<BaseLocalizationLocalDataSource>(),
  _entry<BaseProfileRemoteDataSource>(),
  _entry<BaseCouponsRemoteDataSource>(),
  _entry<BaseAppVersionRemoteDataSource>(),
  _entry<BaseAuthRepository>(),
  _entry<BaseSecureStorageRepository>(),
  _entry<BaseTokenRepository>(),
  _entry<BaseLocalizationRepository>(),
  _entry<BaseProfileRepository>(),
  _entry<BaseCouponsRepository>(),
  _entry<BaseAppVersionRepository>(),
  _entry<BaseAppConfigRemoteDataSource>(),
  _entry<BaseAppConfigRepository>(),
  _entry<LoginUseCase>(),
  _entry<LogoutUseCase>(),
  _entry<GetCurrentUserUseCase>(),
  _entry<GoogleSignInUseCase>(),
  _entry<GoogleSignOutUseCase>(),
  _entry<SaveCredentialsUseCase>(),
  _entry<LoadCredentialsUseCase>(),
  _entry<ClearCredentialsUseCase>(),
  _entry<SaveTokenUseCase>(),
  _entry<GetTokenUseCase>(),
  _entry<ValidateTokenUseCase>(),
  _entry<CheckAuthStatusUseCase>(),
  _entry<ClearTokenUseCase>(),
  _entry<ResendVerificationEmailUseCase>(),
  _entry<ResendPasswordResetOtpUseCase>(),
  _entry<VerifyPasswordResetOtpUseCase>(),
  _entry<ResetPasswordUseCase>(),
  _entry<SendPasswordResetOtpAuthenticatedUseCase>(),
  _entry<VerifyPasswordResetOtpAuthenticatedUseCase>(),
  _entry<ResetPasswordAuthenticatedUseCase>(),
  _entry<GetProfileUseCase>(),
  _entry<UpdateProfileUseCase>(),
  _entry<ChangePasswordUseCase>(),
  _entry<ChangeEmailUseCase>(),
  _entry<ConfirmEmailChangeUseCase>(),
  _entry<SendDeleteAccountOtpUseCase>(),
  _entry<VerifyDeleteAccountOtpUseCase>(),
  _entry<CheckAppVersionUseCase>(),
  _entry<GetLegalUrlsUseCase>(),
  _entry<GetContactInfoUseCase>(),
  _entry<AuthBloc>(),
  _entry<LocalizationBloc>(),
  _entry<ThemeBloc>(),
  _entry<CountdownBloc>(),
  _entry<ProfileBloc>(),
  _entry<CouponsBloc>(),
  _entry<AppVersionBloc>(),
  _entry<SplashBloc>(),
  _entry<BankRemoteDataSource>(),
  _entry<BaseBankRepository>(),
  _entry<GetDriverBalanceUseCase>(),
  _entry<RecordRestaurantPaymentUseCase>(),
  _entry<RecordSystemPaymentUseCase>(),
  _entry<GetTransactionsUseCase>(),
  _entry<AnswerPaymentUseCase>(),
  _entry<RecordPlatformPaymentUseCase>(),
  _entry<BankBloc>(),
  _entry<BaseUsersRemoteDataSource>(),
  _entry<BaseUsersRepository>(),
  _entry<GetUsersUseCase>(),
  _entry<ApproveUserUseCase>(),
  _entry<RejectUserUseCase>(),
  _entry<SuspendUserUseCase>(),
  _entry<ActivateUserUseCase>(),
  _entry<UsersBloc>(),
  _entry<BaseDeliveryAreasRemoteDataSource>(),
  _entry<BaseDeliveryAreasRepository>(),
  _entry<GetDeliveryAreasUseCase>(),
  _entry<SaveDeliveryAreaUseCase>(),
  _entry<SwitchDeliveryAreaUseCase>(),
  _entry<DeleteDeliveryAreaUseCase>(),
  _entry<DeliveryAreasBloc>(),
  _entry<BaseDashboardRemoteDataSource>(),
  _entry<BaseDashboardRepository>(),
  _entry<DashboardBloc>(),
]);
