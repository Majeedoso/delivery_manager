import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/auth/domain/usecases/save_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/domain/usecases/load_credentials_usecase.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/auth/presentation/helpers/auth_navigation_helper.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/widgets/error_dialog.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/services/logging_service.dart';

/// Login screen for user authentication
///
/// This screen provides:
/// - Email and password login form
/// - "Remember me" functionality (saves credentials locally)
/// - Google Sign-In option
/// - Link to sign-up screen
/// - Link to forgot password screen
/// - Language selection option
///
/// After successful login, the screen navigates to the appropriate screen
/// based on user status (MainScreen, AccountStatusScreen, or LoginScreen)
/// using AuthNavigationHelper.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  /// Route name for navigation
  static const String route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Load saved credentials on screen initialization
  Future<void> _loadSavedCredentials() async {
    final loadCredentialsUseCase = sl<LoadCredentialsUseCase>();
    final result = await loadCredentialsUseCase(const NoParameters());

    result.fold(
      (failure) {
        // Handle error silently - credentials just won't be loaded
      },
      (credentials) {
        if (credentials['rememberMe'] == 'true') {
          setState(() {
            _emailController.text = credentials['email'] ?? '';
            _passwordController.text = credentials['password'] ?? '';
            _rememberMe = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        final logger = sl<LoggingService>();
        print(
          '🔵 [LOGIN_SCREEN] Received state - requestState: ${state.requestState}, isAuthenticated: ${state.isAuthenticated}',
        );
        print(
          '🔵 [LOGIN_SCREEN] User: ${state.user?.email}, status: ${state.user?.status}, role: ${state.user?.role}',
        );
        logger.debug(
          'LoginScreen: Received state - requestState: ${state.requestState}, isAuthenticated: ${state.isAuthenticated}',
        );
        if (state.requestState == RequestState.loaded &&
            state.isAuthenticated) {
          print(
            '🔵 [LOGIN_SCREEN] Authentication successful, navigating based on user status...',
          );
          print(
            '🔵 [LOGIN_SCREEN] User isPendingApproval: ${state.user?.isPendingApproval}',
          );
          print('🔵 [LOGIN_SCREEN] User isApproved: ${state.user?.isApproved}');
          logger.info(
            'LoginScreen: Authentication successful, navigating based on user status...',
          );
          AuthNavigationHelper.navigateBasedOnUserStatus(context, state.user);
        } else if (state.requestState == RequestState.error) {
          print('🔴 [LOGIN_SCREEN] Error: ${state.message}');
          // Check for actionable errors that should show a dialog
          final errorMessage = state.message.toLowerCase();

          // Role mismatch error - show informative dialog
          if (errorMessage.contains('this account is for') ||
              errorMessage.contains('please use the') ||
              (errorMessage.contains('app') &&
                  errorMessage.contains('users'))) {
            ErrorDialog.showRoleMismatch(context, message: state.message);
          }
          // Account not found error - show dialog
          else if (errorMessage.contains('account not found') ||
              errorMessage.contains('please sign up first')) {
            ErrorDialog.showAccountNotFound(context, message: state.message);
          }
          // Invalid credentials - show dialog
          else if (errorMessage.contains('invalid') &&
              (errorMessage.contains('email') ||
                  errorMessage.contains('password') ||
                  errorMessage.contains('credentials'))) {
            ErrorDialog.showInvalidCredentials(context);
          }
          // Other errors - show snackbar
          else {
            ErrorSnackBar.show(context, state.message);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.requestState == RequestState.loading;

        final List<Widget> stackChildren = <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: MaterialTheme.getGradientBackground(context),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: MaterialTheme.getPaddingHorizontal(
                  horizontal: MaterialTheme.getSpacing(
                    'paddingHorizontalMedium',
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 700, // Maximum width for desktop
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          48,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            // Logo Section
                            Container(
                              margin: EdgeInsets.only(top: 2.h, bottom: 4.h),
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 18.w,
                                color: const Color(0xFFFF892D),
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Email Field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade200.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.email,
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey[400],
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 2.h,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterEmail;
                                  }
                                  if (!value.contains('@')) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterValidEmail;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            MaterialTheme.getSpacingVertical(
                              vertical: MaterialTheme.getSpacing(
                                'spacingVerticalSmall',
                              ),
                            ),

                            // Password Field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade200.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.password,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[400],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                    borderSide: BorderSide(
                                      color: Colors.orange.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 2.h,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterPassword;
                                  }
                                  if (value.length < 6) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.passwordMinLength;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            MaterialTheme.getSpacingVertical(
                              vertical: MaterialTheme.getSpacing(
                                'spacingVerticalSmall',
                              ),
                            ),

                            // Remember Me and Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          fillColor: WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                          checkColor: Colors.black,
                                          side: BorderSide.none,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      AppLocalizations.of(context)!.rememberMe,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/forgot-password',
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.forgotPassword,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: const Color(0xFFFF5C00),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            MaterialTheme.getSpacingVertical(
                              vertical: MaterialTheme.getSpacing(
                                'spacingVerticalSmall',
                              ),
                            ),

                            // Login Button
                            Container(
                              width: double.infinity,
                              height: 7.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFB824),
                                    Color(0xFFFF5000),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(4.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF5000,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    state.requestState == RequestState.loading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final saveCredentialsUseCase =
                                              sl<SaveCredentialsUseCase>();
                                          await saveCredentialsUseCase(
                                            SaveCredentialsParameters(
                                              email: _emailController.text
                                                  .trim(),
                                              password:
                                                  _passwordController.text,
                                              rememberMe: _rememberMe,
                                            ),
                                          );
                                          if (mounted) {
                                            context.read<AuthBloc>().add(
                                              LoginEvent(
                                                email: _emailController.text
                                                    .trim(),
                                                password:
                                                    _passwordController.text,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.login_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      AppLocalizations.of(context)!.login,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            MaterialTheme.getSpacingVertical(
                              vertical: MaterialTheme.getSpacing(
                                'spacingVerticalSmall',
                              ),
                            ),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[300]),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.or.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[300]),
                                ),
                              ],
                            ),
                            MaterialTheme.getSpacingVertical(
                              vertical: MaterialTheme.getSpacing(
                                'spacingVerticalSmall',
                              ),
                            ),

                            // Google Sign-In Button
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade200.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 7.h,
                                child: OutlinedButton(
                                  onPressed:
                                      state.requestState == RequestState.loading
                                      ? null
                                      : () => context.read<AuthBloc>().add(
                                          GoogleSignInEvent(),
                                        ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.orange.shade200,
                                      width: 2,
                                    ),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.w),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google_logo.png',
                                        width: 6.w,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.g_mobiledata),
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.signInWithGoogle,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            MaterialTheme.getSpacingVertical(
                              vertical: MaterialTheme.getSpacing(
                                'spacingVerticalSmall',
                              ),
                            ),

                            // Footer Links and Copyright
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.dontHaveAccount,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pushReplacementNamed(
                                          AppRoutes.signupChoice,
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.signUp,
                                        style: TextStyle(
                                          color: const Color(0xFFFF5C00),
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "© 2024. All rights reserved.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 18.sp,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];

        // Add loading overlay if loading
        if (isLoading) {
          stackChildren.add(
            AbsorbPointer(
              child: MaterialTheme.getFullPageLoadingOverlay(context),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFEF8F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEF8F1),
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)!.login,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.grey[700],
                  size: 24.sp,
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(SettingsScreen.route),
              ),
            ],
          ),
          body: Stack(children: stackChildren),
        );
      },
    );
  }
}
