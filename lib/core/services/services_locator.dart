import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../network/api_constance.dart';
import '../utils/app_timeouts.dart';
import 'countdown_service.dart';
import 'theme_service.dart';
import 'logging_service.dart';
import '../../features/theme/presentation/controller/theme_bloc.dart';
import '../../features/countdown/presentation/controller/countdown_bloc.dart';
import '../../features/auth/data/datasource/auth_local_data_source.dart';
import '../../features/auth/data/datasource/auth_remote_data_source.dart';
import '../../features/auth/data/datasource/google_auth_remote_data_source.dart';
import '../../features/auth/data/datasource/secure_storage_local_data_source.dart';
import '../../features/auth/data/datasource/token_local_data_source.dart';
import '../../features/auth/data/datasource/token_remote_data_source.dart';
import '../../features/auth/data/repository/auth_repository.dart';
import '../../features/auth/data/repository/secure_storage_repository.dart';
import '../../features/auth/data/repository/token_repository.dart';
import '../../features/auth/domain/repository/base_auth_repository.dart';
import '../../features/auth/domain/repository/base_secure_storage_repository.dart';
import '../../features/auth/domain/repository/base_token_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/google_sign_in_usecase.dart';
import '../../features/auth/domain/usecases/google_sign_up_usecase.dart';
import '../../features/auth/domain/usecases/google_sign_out_usecase.dart';
import '../../features/auth/domain/usecases/save_credentials_usecase.dart';
import '../../features/auth/domain/usecases/load_credentials_usecase.dart';
import '../../features/auth/domain/usecases/clear_credentials_usecase.dart';
import '../../features/auth/domain/usecases/save_token_usecase.dart';
import '../../features/auth/domain/usecases/get_token_usecase.dart';
import '../../features/auth/domain/usecases/validate_token_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/clear_token_usecase.dart';
import '../../features/auth/domain/usecases/resend_verification_email_usecase.dart';
import '../../features/auth/domain/usecases/resend_password_reset_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/send_password_reset_otp_authenticated_usecase.dart';
import '../../features/auth/domain/usecases/verify_password_reset_otp_authenticated_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_authenticated_usecase.dart';
import '../../features/auth/presentation/controller/auth_bloc.dart';
import '../../features/auth/presentation/controller/splash_bloc.dart';
import '../../features/localization/data/datasource/localization_local_data_source.dart';
import '../../features/localization/data/repository/localization_repository.dart';
import '../../features/localization/domain/repository/base_localization_repository.dart';
import '../../features/localization/presentation/controller/localization_bloc.dart';
import '../../features/profile/data/datasource/profile_local_data_source.dart';
import '../../features/profile/data/datasource/profile_remote_data_source.dart';
import '../../features/profile/data/repository/profile_repository.dart';
import '../../features/profile/domain/repository/base_profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../features/profile/domain/usecases/change_email_usecase.dart';
import '../../features/profile/domain/usecases/confirm_email_change_usecase.dart';
import '../../features/profile/domain/usecases/send_delete_account_otp_usecase.dart';
import '../../features/profile/domain/usecases/verify_delete_account_otp_usecase.dart';
import '../../features/profile/presentation/controller/profile_bloc.dart';
import '../../features/app_version/data/datasource/app_version_remote_data_source.dart';
import '../../features/app_version/data/repository/app_version_repository.dart';
import '../../features/app_version/domain/repository/base_app_version_repository.dart';
import '../../features/app_version/domain/usecases/check_app_version_usecase.dart';
import '../../features/app_version/presentation/controller/app_version_bloc.dart';
import '../../features/app_config/data/datasource/app_config_remote_data_source.dart';
import '../../features/app_config/data/repository/app_config_repository.dart';
import '../../features/app_config/domain/repository/base_app_config_repository.dart';
import '../../features/app_config/domain/usecases/get_legal_urls_usecase.dart';
import '../../features/app_config/domain/usecases/get_contact_info_usecase.dart';
import '../../features/bank/data/datasource/bank_remote_data_source.dart';
import '../../features/bank/data/repositories/bank_repository_impl.dart';
import '../../features/bank/domain/repositories/base_bank_repository.dart';
import '../../features/bank/domain/usecases/get_driver_balance_usecase.dart';
import '../../features/bank/domain/usecases/record_restaurant_payment_usecase.dart';
import '../../features/bank/domain/usecases/record_system_payment_usecase.dart';
import '../../features/bank/domain/usecases/get_transactions_usecase.dart';
import '../../features/bank/presentation/controller/bank_bloc.dart';
import '../services/api_service.dart';
import '../interceptors/retry_interceptor.dart';

final sl = GetIt.instance;

class ServicesLocator {
  /// Reset GetIt instance (useful for testing)
  ///
  /// This method safely resets GetIt, clearing all registered services.
  /// It's safe to call even if GetIt is not initialized.
  static void reset() {
    try {
      // Check if GetIt has any registrations before resetting
      // We check for Dio as it's one of the first services registered
      if (sl.isRegistered<Dio>()) {
        sl.reset();
      }
    } catch (e) {
      // If reset fails, try to reset anyway (might be in a bad state)
      try {
        sl.reset(dispose: false);
      } catch (_) {
        // If that also fails, ignore - GetIt might already be reset
      }
    }
  }

  /// Helper function to safely register a service
  /// This prevents "already registered" errors in integration tests
  static void _safeRegister<T extends Object>(T Function() factory) {
    try {
      if (!sl.isRegistered<T>()) {
        sl.registerLazySingleton<T>(factory);
      }
    } catch (e) {
      // If registration fails, that's okay - might already be registered
    }
  }

  Future<void> init() async {
    // Always reset before initialization (useful for integration tests)
    // This prevents "already registered" errors when main() is called multiple times
    try {
      // Try to reset - this is safe even if nothing is registered
      sl.reset(dispose: false);
    } catch (e) {
      // If reset fails, that's okay - services might not be registered yet
      // The registration checks below will handle duplicates
    }
    // External
    // Register Dio
    _safeRegister<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstance.baseUrl,
          connectTimeout: AppTimeouts.apiRequest,
          receiveTimeout: AppTimeouts.apiRequest,
          sendTimeout: AppTimeouts.apiRequest,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add authentication and language interceptor
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Get token from secure storage
            final tokenRepository = sl<BaseTokenRepository>();
            final tokenResult = await tokenRepository.getToken();

            tokenResult.fold(
              (failure) {
                // Token retrieval failed
              },
              (token) {
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
              },
            );

            // Add Accept-Language header based on current app language
            try {
              final sharedPreferences = sl<SharedPreferences>();
              final languageCode =
                  sharedPreferences.getString('selected_language') ?? 'ar';
              // Validate language code (must be one of: ar, en, fr)
              final validLanguages = ['ar', 'en', 'fr'];
              final validLanguageCode = validLanguages.contains(languageCode)
                  ? languageCode
                  : 'ar';
              options.headers['Accept-Language'] = validLanguageCode;
            } catch (e) {
              // If language retrieval fails, default to Arabic
              options.headers['Accept-Language'] = 'ar';
            }

            handler.next(options);
          },
          onError: (error, handler) {
            handler.next(error);
          },
        ),
      );

      // Add retry interceptor after auth (so retries include auth token in headers)
      // Note: Logger might not be registered yet, but interceptor has fallback
      dio.interceptors.add(
        RetryInterceptor(maxRetries: 3, retryDelay: const Duration(seconds: 2)),
      );

      return dio;
    });

    // Register FirebaseAuth
    _safeRegister<FirebaseAuth>(() => FirebaseAuth.instance);

    // Register GoogleSignIn
    _safeRegister<GoogleSignIn>(
      () => GoogleSignIn(
        // Add scopes for email and profile access
        scopes: ['email', 'profile'],
        // Force account picker to show every time (prevents auto-selection from other apps)
        signInOption: SignInOption.standard,
      ),
    );

    // Register SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _safeRegister<SharedPreferences>(() => sharedPreferences);

    // Logging Service - should be registered early for use throughout the app
    _safeRegister<LoggingService>(() => LoggingService());

    // Countdown Service
    _safeRegister<CountdownService>(() => CountdownService());

    // Theme Service - uses same SharedPreferences instance as language (same pattern)
    _safeRegister<ThemeService>(() => ThemeService(sl<SharedPreferences>()));

    // ApiService - wrapper around Dio for API calls
    _safeRegister<ApiService>(
      () => ApiService(
        baseUrl: ApiConstance.baseUrl,
        logger: sl<LoggingService>(),
      ),
    );

    // Data Sources
    sl.registerLazySingleton<BaseAuthRemoteDataSource>(
      () => AuthRemoteDataSource(dio: sl()),
    );
    sl.registerLazySingleton<BaseAuthLocalDataSource>(
      () => AuthLocalDataSource(sharedPreferences: sl()),
    );
    sl.registerLazySingleton<BaseGoogleAuthRemoteDataSource>(
      () => GoogleAuthRemoteDataSource(
        firebaseAuth: sl(),
        googleSignIn: sl(),
        dio: sl(),
      ),
    );
    sl.registerLazySingleton<BaseSecureStorageLocalDataSource>(
      () => SecureStorageLocalDataSource(),
    );
    sl.registerLazySingleton<BaseTokenLocalDataSource>(
      () => TokenLocalDataSource(),
    );
    sl.registerLazySingleton<BaseTokenRemoteDataSource>(
      () => TokenRemoteDataSource(dio: sl()),
    );
    sl.registerLazySingleton<BaseLocalizationLocalDataSource>(
      () => LocalizationLocalDataSource(sharedPreferences: sl()),
    );
    sl.registerLazySingleton<BaseProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(dio: sl(), tokenRepository: sl()),
    );
    sl.registerLazySingleton<BaseProfileLocalDataSource>(
      () => ProfileLocalDataSource(sharedPreferences: sl()),
    );

    // App Version Data Sources
    sl.registerLazySingleton<BaseAppVersionRemoteDataSource>(
      () => AppVersionRemoteDataSource(dio: sl()),
    );

    // Repository
    sl.registerLazySingleton<BaseAuthRepository>(
      () => AuthRepository(
        baseAuthRemoteDataSource: sl(),
        baseAuthLocalDataSource: sl(),
        baseGoogleAuthRemoteDataSource: sl(),
        baseTokenRepository: sl(),
      ),
    );
    sl.registerLazySingleton<BaseSecureStorageRepository>(
      () => SecureStorageRepository(sl()),
    );
    sl.registerLazySingleton<BaseTokenRepository>(
      () => TokenRepository(localDataSource: sl(), remoteDataSource: sl()),
    );
    sl.registerLazySingleton<BaseLocalizationRepository>(
      () => LocalizationRepository(baseLocalizationLocalDataSource: sl()),
    );
    sl.registerLazySingleton<BaseProfileRepository>(
      () => ProfileRepository(
        baseProfileRemoteDataSource: sl(),
        baseProfileLocalDataSource: sl(),
      ),
    );

    // App Version Repository
    sl.registerLazySingleton<BaseAppVersionRepository>(
      () => AppVersionRepository(remoteDataSource: sl()),
    );

    // App Config Data Source
    sl.registerLazySingleton<BaseAppConfigRemoteDataSource>(
      () => AppConfigRemoteDataSourceImpl(apiService: sl()),
    );

    // App Config Repository
    sl.registerLazySingleton<BaseAppConfigRepository>(
      () => AppConfigRepository(remoteDataSource: sl()),
    );

    // Use Cases
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => RegisterUseCase(sl()));
    sl.registerLazySingleton(() => LogoutUseCase(sl()));
    sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
    sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
    sl.registerLazySingleton(() => GoogleSignUpUseCase(sl()));
    sl.registerLazySingleton(() => GoogleSignOutUseCase(sl()));
    sl.registerLazySingleton(() => SaveCredentialsUseCase(sl()));
    sl.registerLazySingleton(() => LoadCredentialsUseCase(sl()));
    sl.registerLazySingleton(() => ClearCredentialsUseCase(sl()));
    sl.registerLazySingleton(() => SaveTokenUseCase(sl()));
    sl.registerLazySingleton(() => GetTokenUseCase(sl()));
    sl.registerLazySingleton(() => ValidateTokenUseCase(sl()));
    sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
    sl.registerLazySingleton(() => ClearTokenUseCase(sl()));
    sl.registerLazySingleton(() => ResendVerificationEmailUseCase(sl()));
    sl.registerLazySingleton(() => ResendPasswordResetOtpUseCase(sl()));
    sl.registerLazySingleton(() => VerifyPasswordResetOtpUseCase(sl()));
    sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
    sl.registerLazySingleton(
      () => SendPasswordResetOtpAuthenticatedUseCase(sl()),
    );
    sl.registerLazySingleton(
      () => VerifyPasswordResetOtpAuthenticatedUseCase(sl()),
    );
    sl.registerLazySingleton(() => ResetPasswordAuthenticatedUseCase(sl()));
    sl.registerLazySingleton(() => GetProfileUseCase(sl()));
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
    sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
    sl.registerLazySingleton(() => ChangeEmailUseCase(sl()));
    sl.registerLazySingleton(() => ConfirmEmailChangeUseCase(sl()));
    sl.registerLazySingleton(() => SendDeleteAccountOtpUseCase(sl()));
    sl.registerLazySingleton(() => VerifyDeleteAccountOtpUseCase(sl()));

    // App Version Use Cases
    sl.registerLazySingleton(() => CheckAppVersionUseCase(sl()));
    sl.registerLazySingleton(() => GetLegalUrlsUseCase(sl()));
    sl.registerLazySingleton(() => GetContactInfoUseCase(sl()));

    // Bloc
    sl.registerFactory(
      () => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        googleSignInUseCase: sl(),
        googleSignUpUseCase: sl(),
        googleSignOutUseCase: sl(),
        saveTokenUseCase: sl(),
        checkAuthStatusUseCase: sl(),
        clearTokenUseCase: sl(),
        resendVerificationEmailUseCase: sl(),
        resendPasswordResetOtpUseCase: sl(),
        verifyPasswordResetOtpUseCase: sl(),
        resetPasswordUseCase: sl(),
        sendPasswordResetOtpAuthenticatedUseCase: sl(),
        verifyPasswordResetOtpAuthenticatedUseCase: sl(),
        resetPasswordAuthenticatedUseCase: sl(),
        loadCredentialsUseCase: sl(),
        saveCredentialsUseCase: sl(),
        logger: sl(),
      ),
    );
    sl.registerFactory(() => LocalizationBloc(sl()));
    sl.registerFactory(() => ThemeBloc(sharedPreferences: sl(), logger: sl()));
    sl.registerFactory(() => CountdownBloc(logger: sl()));
    sl.registerFactory(
      () => ProfileBloc(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        changePasswordUseCase: sl(),
        changeEmailUseCase: sl(),
        confirmEmailChangeUseCase: sl(),
        sendDeleteAccountOtpUseCase: sl(),
        verifyDeleteAccountOtpUseCase: sl(),
        loadCredentialsUseCase: sl(),
        saveCredentialsUseCase: sl(),
        logger: sl(),
      ),
    );

    // App Version BLoC
    sl.registerFactory(() => AppVersionBloc(checkAppVersionUseCase: sl()));

    // Note: SplashBloc authBloc and appVersionBloc should be provided from context, not service locator
    // We'll pass null and set it up in the widget tree
    sl.registerFactory(
      () => SplashBloc(
        authBloc: null, // Will be set from context in the widget tree
        appVersionBloc: null, // Will be set from context in the widget tree
        logger: sl(),
      ),
    );

    // Bank Data Source
    sl.registerLazySingleton<BankRemoteDataSource>(
      () => BankRemoteDataSourceImpl(dio: sl(), logger: sl()),
    );

    // Bank Repository
    sl.registerLazySingleton<BaseBankRepository>(
      () => BankRepositoryImpl(remoteDataSource: sl()),
    );

    // Bank Use Cases
    sl.registerLazySingleton(() => GetDriverBalanceUseCase(sl()));
    sl.registerLazySingleton(() => RecordRestaurantPaymentUseCase(sl()));
    sl.registerLazySingleton(() => RecordSystemPaymentUseCase(sl()));
    sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));

    // Bank BLoC
    sl.registerFactory(
      () => BankBloc(
        getDriverBalanceUseCase: sl(),
        recordRestaurantPaymentUseCase: sl(),
        recordSystemPaymentUseCase: sl(),
        getTransactionsUseCase: sl(),
        bankRepository: sl<BaseBankRepository>(),
      ),
    );
  }
}
