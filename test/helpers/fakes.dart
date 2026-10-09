import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_manager/core/services/device_info_service.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_event.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_state.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/bank/data/datasource/bank_remote_data_source.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';
import 'package:delivery_manager/features/bank/domain/usecases/answer_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/get_driver_balance_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/get_transactions_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_restaurant_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_system_payment_usecase.dart';
import 'package:delivery_manager/features/bank/domain/usecases/record_platform_payment_usecase.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_event.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_state.dart';
import 'package:delivery_manager/features/auth/data/datasource/google_auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/secure_storage_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_remote_data_source.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_secure_storage_repository.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/clear_token_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
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
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_authenticated_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_state.dart';
import 'package:delivery_manager/features/coupons/data/datasource/coupons_remote_data_source.dart';
import 'package:delivery_manager/features/coupons/domain/repository/base_coupons_repository.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/dashboard/data/datasource/dashboard_remote_data_source.dart';
import 'package:delivery_manager/features/dashboard/domain/repository/base_dashboard_repository.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_event.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_state.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_event.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_state.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_bloc.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_event.dart';
import 'package:delivery_manager/features/theme/presentation/controller/theme_state.dart';
import 'package:delivery_manager/features/users/data/datasource/users_remote_data_source.dart';
import 'package:delivery_manager/features/users/domain/repository/base_users_repository.dart';
import 'package:delivery_manager/features/users/domain/usecases/activate_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/approve_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/get_users_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/reject_user_usecase.dart';
import 'package:delivery_manager/features/users/domain/usecases/suspend_user_usecase.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_bloc.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/domain/usecases/delivery_areas_usecases.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_bloc.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_event.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_state.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_event.dart';
import 'package:delivery_manager/features/users/presentation/controller/users_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

/// One mocktail class per bloc, use case, repository and data source that a
/// test replaces, grouped by feature. Grows one feature at a time.

// ---------------------------------------------------------------- Blocs

class MockAppVersionBloc extends MockBloc<AppVersionEvent, AppVersionState>
    implements AppVersionBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSplashBloc extends MockBloc<SplashEvent, SplashState>
    implements SplashBloc {}

class MockCountdownBloc extends MockBloc<CountdownEvent, CountdownState>
    implements CountdownBloc {}

class MockLocalizationBloc
    extends MockBloc<LocalizationEvent, LocalizationState>
    implements LocalizationBloc {}

class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState>
    implements ThemeBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockUsersBloc extends MockBloc<UsersEvent, UsersState>
    implements UsersBloc {}

class MockCouponsBloc extends MockBloc<CouponsEvent, CouponsState>
    implements CouponsBloc {}

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

class MockBankBloc extends MockBloc<BankEvent, BankState> implements BankBloc {}

// ----------------------------------------------------------------- Auth

class MockTokenRepository extends Mock implements BaseTokenRepository {}

class MockAuthRepository extends Mock implements BaseAuthRepository {}

class MockSecureStorageRepository extends Mock
    implements BaseSecureStorageRepository {}

class MockAuthRemoteDataSource extends Mock
    implements BaseAuthRemoteDataSource {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseUser extends Mock implements User {}

class MockDeviceInfoService extends Mock implements DeviceInfoService {}

class MockGoogleAuthRemoteDataSource extends Mock
    implements BaseGoogleAuthRemoteDataSource {}

class MockTokenRemoteDataSource extends Mock
    implements BaseTokenRemoteDataSource {}

class MockTokenLocalDataSource extends Mock
    implements BaseTokenLocalDataSource {}

class MockSecureStorageLocalDataSource extends Mock
    implements BaseSecureStorageLocalDataSource {}

class MockLoadCredentialsUseCase extends Mock
    implements LoadCredentialsUseCase {}

class MockSaveCredentialsUseCase extends Mock
    implements SaveCredentialsUseCase {}

class MockCheckAuthStatusUseCase extends Mock
    implements CheckAuthStatusUseCase {}

class MockClearTokenUseCase extends Mock implements ClearTokenUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockGoogleSignOutUseCase extends Mock implements GoogleSignOutUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockResendPasswordResetOtpUseCase extends Mock
    implements ResendPasswordResetOtpUseCase {}

class MockResendVerificationEmailUseCase extends Mock
    implements ResendVerificationEmailUseCase {}

class MockResetPasswordAuthenticatedUseCase extends Mock
    implements ResetPasswordAuthenticatedUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockSaveTokenUseCase extends Mock implements SaveTokenUseCase {}

class MockSendPasswordResetOtpAuthenticatedUseCase extends Mock
    implements SendPasswordResetOtpAuthenticatedUseCase {}

class MockVerifyPasswordResetOtpAuthenticatedUseCase extends Mock
    implements VerifyPasswordResetOtpAuthenticatedUseCase {}

class MockVerifyPasswordResetOtpUseCase extends Mock
    implements VerifyPasswordResetOtpUseCase {}

// ---------------------------------------------------------------- Users

class MockUsersRepository extends Mock implements BaseUsersRepository {}

class MockUsersRemoteDataSource extends Mock
    implements BaseUsersRemoteDataSource {}

class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}

class MockRecordPlatformPaymentUseCase extends Mock
    implements RecordPlatformPaymentUseCase {}

class MockDeliveryAreasBloc
    extends MockBloc<DeliveryAreasEvent, DeliveryAreasState>
    implements DeliveryAreasBloc {}

class MockGetDeliveryAreasUseCase extends Mock
    implements GetDeliveryAreasUseCase {}

class MockSaveDeliveryAreaUseCase extends Mock
    implements SaveDeliveryAreaUseCase {}

class MockSwitchDeliveryAreaUseCase extends Mock
    implements SwitchDeliveryAreaUseCase {}

class MockDeleteDeliveryAreaUseCase extends Mock
    implements DeleteDeliveryAreaUseCase {}

class MockApproveUserUseCase extends Mock implements ApproveUserUseCase {}

class MockRejectUserUseCase extends Mock implements RejectUserUseCase {}

class MockSuspendUserUseCase extends Mock implements SuspendUserUseCase {}

class MockActivateUserUseCase extends Mock implements ActivateUserUseCase {}

// -------------------------------------------------------------- Coupons

class MockCouponsRepository extends Mock implements BaseCouponsRepository {}

class MockCouponsRemoteDataSource extends Mock
    implements BaseCouponsRemoteDataSource {}

// ------------------------------------------------------------- Settings

class MockDashboardRepository extends Mock implements BaseDashboardRepository {}

class MockDashboardRemoteDataSource extends Mock
    implements BaseDashboardRemoteDataSource {}

// ----------------------------------------------------------------- Bank

class MockBankRepository extends Mock implements BaseBankRepository {}

class MockBankRemoteDataSource extends Mock implements BankRemoteDataSource {}

class MockGetDriverBalanceUseCase extends Mock
    implements GetDriverBalanceUseCase {}

class MockRecordRestaurantPaymentUseCase extends Mock
    implements RecordRestaurantPaymentUseCase {}

class MockRecordSystemPaymentUseCase extends Mock
    implements RecordSystemPaymentUseCase {}

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

class MockAnswerPaymentUseCase extends Mock implements AnswerPaymentUseCase {}

// ------------------------------------------------------- Event fallbacks

class _AnyAppVersionEvent extends Fake implements AppVersionEvent {}

class _AnyAuthEvent extends Fake implements AuthEvent {}

class _AnySplashEvent extends Fake implements SplashEvent {}

class _AnyCountdownEvent extends Fake implements CountdownEvent {}

class _AnyLocalizationEvent extends Fake implements LocalizationEvent {}

class _AnyThemeEvent extends Fake implements ThemeEvent {}

class _AnyProfileEvent extends Fake implements ProfileEvent {}

class _AnyUsersEvent extends Fake implements UsersEvent {}

class _AnyDeliveryAreasEvent extends Fake implements DeliveryAreasEvent {}

class _AnyCouponsEvent extends Fake implements CouponsEvent {}

class _AnyDashboardEvent extends Fake implements DashboardEvent {}

class _AnyBankEvent extends Fake implements BankEvent {}

/// The values `any()` stands for in `when(...)`: run once per test file, in
/// `setUpAll`.
void registerFallbacks() {
  registerFallbackValue(const NoParameters());
  registerFallbackValue(const LoginParameters(email: '', password: ''));
  registerFallbackValue(const SaveTokenParameters(token: ''));
  registerFallbackValue(ResendPasswordResetOtpParameters(email: ''));
  registerFallbackValue(
    const VerifyPasswordResetOtpParameters(email: '', otp: ''),
  );
  registerFallbackValue(
    const ResetPasswordParameters(
      email: '',
      otp: '',
      password: '',
      passwordConfirmation: '',
    ),
  );
  registerFallbackValue(
    const VerifyPasswordResetOtpAuthenticatedParameters(otp: ''),
  );
  registerFallbackValue(
    const ResetPasswordAuthenticatedParameters(
      otp: '',
      newPassword: '',
      newPasswordConfirmation: '',
    ),
  );
  registerFallbackValue(
    const SaveCredentialsParameters(email: '', password: '', rememberMe: false),
  );
  registerFallbackValue(_AnyAppVersionEvent());
  registerFallbackValue(_AnyAuthEvent());
  registerFallbackValue(_AnySplashEvent());
  registerFallbackValue(_AnyCountdownEvent());
  registerFallbackValue(_AnyLocalizationEvent());
  registerFallbackValue(_AnyThemeEvent());
  registerFallbackValue(_AnyProfileEvent());
  registerFallbackValue(_AnyUsersEvent());
  registerFallbackValue(_AnyDeliveryAreasEvent());
  registerFallbackValue(
    const DeliveryAreaDraft(name: '', latitude: 0, longitude: 0, radiusKm: 1),
  );
  registerFallbackValue(_AnyCouponsEvent());
  registerFallbackValue(_AnyDashboardEvent());
  registerFallbackValue(_AnyBankEvent());
  registerFallbackValue(GetTransactionsParams());
  registerFallbackValue(
    const AnswerPaymentParams(transactionId: 0, confirm: true),
  );
  registerFallbackValue(
    RecordRestaurantPaymentParams(restaurantId: 0, amount: 0),
  );
  registerFallbackValue(RecordSystemPaymentParams(driverId: 0, amount: 0));
  registerFallbackValue(const RecordPlatformPaymentParams(amount: 0));
}
