import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/auth/presentation/screens/splash_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/signup_choice_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/signup_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/reset_password_unauthenticated_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/account_status_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/verify_email_otp_screen.dart';
import 'package:delivery_manager/features/home/presentation/screens/main_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/profile_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_password_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_email_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/verify_email_change_otp_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/reset_password_authenticated_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/verify_delete_account_otp_screen.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/splash_bloc.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/features/settings/presentation/screens/about_screen.dart';
import 'package:delivery_manager/features/localization/presentation/controller/localization_bloc.dart';
import 'package:delivery_manager/features/localization/presentation/screens/language_selection_screen.dart';
import 'package:delivery_manager/features/localization/presentation/screens/first_run_language_screen.dart';
import 'package:delivery_manager/features/app_version/presentation/controller/app_version_bloc.dart';
import 'package:delivery_manager/features/app_version/presentation/screens/update_required_screen.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/profile/presentation/widgets/map_picker_page.dart';
import 'package:delivery_manager/features/bank/presentation/screens/bank_main_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/receivables_payables_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/new_transaction_screen.dart';
import 'package:delivery_manager/features/bank/presentation/screens/bank_archive_screen.dart';
import 'package:delivery_manager/features/bank/presentation/controller/bank_bloc.dart';
import 'package:delivery_manager/features/bank/presentation/screens/driver_debt_details_screen.dart';
import 'package:delivery_manager/features/bank/domain/entities/restaurant_debt.dart';

/// Route generator for the application
///
/// This class handles all route generation and navigation setup.
/// It provides a centralized location for managing routes and their
/// associated BLoC providers.
class RouteGenerator {
  /// Generate routes for the MaterialApp
  ///
  /// Returns a map of route names to route builders.
  /// Each route is configured with the necessary BLoC providers.
  static Map<String, WidgetBuilder> generateRoutes() {
    return {
      AppRoutes.firstRunLanguage: (context) => BlocProvider.value(
        value: context.read<LocalizationBloc>(),
        child: const FirstRunLanguageScreen(),
      ),
      AppRoutes.splash: (context) => BlocProvider.value(
        value: sl<AppVersionBloc>(),
        child: BlocProvider(
          create: (context) => SplashBloc(
            authBloc: context.read<AuthBloc>(),
            appVersionBloc: context.read<AppVersionBloc>(),
          ),
          child: const SplashScreen(),
        ),
      ),
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.signupChoice: (context) => const SignupChoiceScreen(),
      AppRoutes.signup: (context) => const SignupScreen(),
      AppRoutes.main: (context) => const MainScreen(),
      AppRoutes.profile: (context) => BlocProvider(
        create: (context) => sl<ProfileBloc>(),
        child: const ProfileScreen(),
      ),
      AppRoutes.editProfile: (context) => BlocProvider(
        create: (context) => sl<ProfileBloc>()..add(const GetProfileEvent()),
        child: const EditProfileScreen(),
      ),
      AppRoutes.changePassword: (context) => BlocProvider(
        create: (context) => sl<ProfileBloc>(),
        child: const ChangePasswordScreen(),
      ),
      AppRoutes.changeEmail: (context) => BlocProvider(
        create: (context) => sl<ProfileBloc>(),
        child: const ChangeEmailScreen(),
      ),
      AppRoutes.verifyEmailChangeOtp: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args == null || args is! Map<String, dynamic>) {
          return const Scaffold(
            body: Center(child: Text('Invalid route arguments')),
          );
        }
        return BlocProvider(
          create: (context) => sl<ProfileBloc>(),
          child: VerifyEmailChangeOtpScreen(
            newEmail: args['newEmail'] as String? ?? '',
          ),
        );
      },
      AppRoutes.resetPasswordAuthenticated: (context) => BlocProvider(
        create: (context) => sl<ProfileBloc>(),
        child: const ResetPasswordAuthenticatedScreen(),
      ),
      AppRoutes.verifyDeleteAccountOtp: (context) => BlocProvider(
        create: (context) => sl<ProfileBloc>(),
        child: const VerifyDeleteAccountOtpScreen(),
      ),
      AppRoutes.settings: (context) => BlocProvider.value(
        value: context.read<LocalizationBloc>(),
        child: BlocProvider.value(
          value: sl<AppVersionBloc>(),
          child: const SettingsScreen(),
        ),
      ),
      AppRoutes.about: (context) => const AboutScreen(),
      AppRoutes.languageSelection: (context) => const LanguageSelectionScreen(),
      AppRoutes.updateRequired: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args == null || args is! Map<String, dynamic>) {
          return const Scaffold(
            body: Center(child: Text('Invalid route arguments')),
          );
        }
        final appVersion = args['appVersion'];
        final userCurrentVersion = args['userCurrentVersion'];
        if (appVersion == null || appVersion is! AppVersion) {
          return const Scaffold(
            body: Center(child: Text('Invalid app version argument')),
          );
        }
        return UpdateRequiredScreen(
          appVersion: appVersion,
          userCurrentVersion: userCurrentVersion as String? ?? 'Unknown',
        );
      },
      AppRoutes.accountStatus: (context) => const AccountStatusScreen(),
      AppRoutes.verifyEmailOtp: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args == null || args is! Map<String, dynamic>) {
          return const Scaffold(
            body: Center(child: Text('Invalid route arguments')),
          );
        }
        return VerifyEmailOtpScreen(email: args['email'] as String? ?? '');
      },
      AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
      AppRoutes.resetPasswordUnauthenticated: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args == null || args is! Map<String, String>) {
          return const Scaffold(
            body: Center(child: Text('Invalid route arguments')),
          );
        }
        return ResetPasswordUnauthenticatedScreen(
          email: args['email'] ?? '',
          otp: args['otp'] ?? '',
        );
      },
      AppRoutes.mapPicker: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args == null || args is! Map<String, dynamic>) {
          return const Scaffold(
            body: Center(child: Text('Invalid route arguments')),
          );
        }
        return MapPickerPage(
          initialLat: args['initialLat'] as double?,
          initialLng: args['initialLng'] as double?,
        );
      },
      // Bank routes
      AppRoutes.bank: (context) => const BankMainScreen(),
      AppRoutes.bankReceivables: (context) => BlocProvider(
        create: (context) => sl<BankBloc>(),
        child: const ReceivablesPayablesScreen(),
      ),
      AppRoutes.bankNewTransaction: (context) => BlocProvider(
        create: (context) => sl<BankBloc>(),
        child: const NewTransactionScreen(),
      ),
      AppRoutes.bankArchive: (context) => BlocProvider(
        create: (context) => sl<BankBloc>(),
        child: const BankArchiveScreen(),
      ),
      AppRoutes.driverDebtDetails: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;

        // Support both Map arguments (with date range) and direct RestaurantDebt
        RestaurantDebt? item;
        String? period;
        DateTime? dateFrom;
        DateTime? dateTo;

        if (args is Map<String, dynamic>) {
          item = args['item'] as RestaurantDebt?;
          period = args['period'] as String?;
          dateFrom = args['dateFrom'] as DateTime?;
          dateTo = args['dateTo'] as DateTime?;
        } else if (args is RestaurantDebt) {
          item = args;
        }

        if (item == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid route arguments')),
          );
        }
        return BlocProvider(
          create: (context) => sl<BankBloc>(),
          child: DriverDebtDetailsScreen(
            debtItem: item,
            initialPeriod: period,
            initialDateFrom: dateFrom,
            initialDateTo: dateTo,
          ),
        );
      },
    };
  }
}
