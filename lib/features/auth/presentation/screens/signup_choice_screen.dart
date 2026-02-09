import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/signup_screen.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/features/auth/presentation/helpers/auth_navigation_helper.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';

/// Sign-up choice screen for selecting registration method
///
/// This screen provides:
/// - "Continue with Google" button (primary option)
/// - "Sign up with Email" button (secondary option)
/// - Link to login screen
/// - Language selection option
///
/// After successful Google sign-up, the screen navigates to the appropriate screen
/// based on user status using AuthNavigationHelper.
class SignupChoiceScreen extends StatefulWidget {
  const SignupChoiceScreen({super.key});

  /// Route name for navigation
  static const String route = '/signup-choice';

  @override
  State<SignupChoiceScreen> createState() => _SignupChoiceScreenState();
}

class _SignupChoiceScreenState extends State<SignupChoiceScreen> {
  /// Handle navigation when "Sign up with Email" is clicked
  /// Checks if user is authenticated but email not verified with active countdown
  Future<void> _handleEmailSignupClick() async {
    try {
      final authLocalDataSource = sl<BaseAuthLocalDataSource>();
      final user = await authLocalDataSource.getCurrentUser();
      final token = await authLocalDataSource.getToken();

      // Check if user is authenticated but email not verified
      if (user != null && token != null && !user.hasVerifiedEmail) {
        // Check if countdown is active (user was in OTP flow)
        final countdownBloc = context.read<CountdownBloc>();
        if (countdownBloc.state.isActive ||
            countdownBloc.state.countdownSeconds > 0) {
          // Navigate to OTP screen if countdown is still active
          final logger = sl<LoggingService>();
          logger.info(
            'SignupChoiceScreen: User authenticated but email not verified with active countdown, navigating to OTP screen...',
          );
          if (mounted) {
            Navigator.of(context).pushNamed(
              AppRoutes.verifyEmailOtp,
              arguments: {'email': user.email},
            );
            return; // Exit early, don't navigate to signup form
          }
        }
      }

      // Normal flow: navigate to signup form
      if (mounted) {
        Navigator.of(context).pushNamed(SignupScreen.route);
      }
    } catch (e) {
      // On error, just navigate to signup form
      final logger = sl<LoggingService>();
      logger.debug(
        'SignupChoiceScreen: Error checking auth state, navigating to signup form: $e',
      );
      if (mounted) {
        Navigator.of(context).pushNamed(SignupScreen.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createAccount),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 24.sp),
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.route);
            },
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.requestState == RequestState.loaded &&
                state.isAuthenticated) {
              final logger = sl<LoggingService>();
              logger.info(
                'SignupChoiceScreen: Google authentication successful, navigating based on user status...',
              );
              // Navigate directly to the appropriate screen based on user status
              // This avoids the issue of splash screen not having the auth state
              AuthNavigationHelper.navigateBasedOnUserStatus(
                context,
                state.user,
              );
            } else if (state.requestState == RequestState.error) {
              ErrorSnackBar.show(context, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state.requestState == RequestState.loading;
            return Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 500, // Maximum width for desktop
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 10.h),

                            Text(
                              AppLocalizations.of(context)!.createAccount,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),

                            Text(
                              'Choose how you want to create your account',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 48),

                            // Google Sign-Up Button (Primary)
                            Builder(
                              builder: (context) {
                                final isDesktop =
                                    MediaQuery.of(context).size.width > 600;
                                final buttonHeight = isDesktop
                                    ? 72.0
                                    : MaterialTheme.getSpacing(
                                        'buttonHeight',
                                      ).h;
                                return SizedBox(
                                  height: buttonHeight,
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.read<AuthBloc>().add(
                                              GoogleSignUpEvent(),
                                            );
                                          },
                                    icon: Image.asset(
                                      'assets/images/google_logo.png',
                                      width: MaterialTheme.getSpacing(
                                        'containerWidthSmall',
                                      ).w,
                                      height: MaterialTheme.getSpacing(
                                        'buttonHeightSmall',
                                      ).h,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.login,
                                              size: MaterialTheme.getSpacing(
                                                'iconButton',
                                              ).sp,
                                            );
                                          },
                                    ),
                                    label: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.signUpWithGoogle,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(
                                        double.infinity,
                                        buttonHeight,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                        side:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const BorderSide(
                                                color: Colors.white,
                                                width: 1.0,
                                              )
                                            : BorderSide.none,
                                      ),
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.transparent
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.or,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            SizedBox(height: 24),

                            // Email Sign-Up Button (Secondary)
                            Builder(
                              builder: (context) {
                                final isDesktop =
                                    MediaQuery.of(context).size.width > 600;
                                final buttonHeight = isDesktop
                                    ? 72.0
                                    : MaterialTheme.getSpacing(
                                        'buttonHeight',
                                      ).h;
                                return SizedBox(
                                  height: buttonHeight,
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : _handleEmailSignupClick,
                                    icon: Icon(
                                      Icons.email,
                                      size: MaterialTheme.getSpacing(
                                        'iconButton',
                                      ).sp,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.signUpWithEmail,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: Size(
                                        double.infinity,
                                        buttonHeight,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      side: BorderSide(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        width: 2.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 32),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.alreadyHaveAccount,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed(LoginScreen.route);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                    alignment: Alignment.bottomCenter,
                                    textStyle: TextStyle(
                                      fontSize: 19.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.login,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Full-page loading overlay
                if (isLoading) MaterialTheme.getFullPageLoadingOverlay(context),
              ],
            );
          },
        ),
      ),
    );
  }
}
