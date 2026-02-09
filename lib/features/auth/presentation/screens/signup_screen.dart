import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/services/logging_service.dart';

/// Sign-up screen for new user registration
///
/// This screen provides:
/// - Registration form with name, email, phone, password, and confirm password
/// - Password validation (minimum 8 characters, must contain uppercase, lowercase, number, and symbol)
/// - Google Sign-Up option
/// - Link to login screen
/// - Language selection option
///
/// After successful registration, the screen navigates to the appropriate screen
/// based on user status (MainScreen, AccountStatusScreen, or LoginScreen)
/// using AuthNavigationHelper.
///
/// Note: New operators require manager approval before accessing the main screen.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  /// Route name for navigation
  static const String route = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signUp),
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
        child: BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.requestState == RequestState.loaded &&
                  state.isAuthenticated) {
                final logger = sl<LoggingService>();
                final user = state.user;

                // Check if email is not verified - navigate to OTP verification screen
                if (user != null && !user.hasVerifiedEmail) {
                  logger.info(
                    'SignUpScreen: User registered but email not verified, navigating to OTP verification...',
                  );
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.verifyEmailOtp,
                    arguments: {'email': user.email},
                  );
                } else {
                  logger.info(
                    'SignUpScreen: Authentication successful, navigating to splash screen to handle navigation...',
                  );
                  // Navigate to splash screen - it will check auth status and navigate to appropriate screen
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
                }
              } else if (state.requestState == RequestState.error) {
                ErrorSnackBar.show(context, state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state.requestState == RequestState.loading;
              return Stack(
                children: [
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  constraints.maxHeight -
                                  48, // Subtract padding
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 700, // Maximum width for desktop
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 24),

                                      // Name Field
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          )!.name,
                                          prefixIcon: const Icon(Icons.person),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your name';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Email Field
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          )!.email,
                                          prefixIcon: const Icon(Icons.email),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Phone Field
                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          )!.phone,
                                          prefixIcon: const Icon(Icons.phone),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          // Phone is optional according to backend validation
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Field
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          )!.password,
                                          prefixIcon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          if (!RegExp(
                                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
                                          ).hasMatch(value)) {
                                            return 'Password must contain uppercase, lowercase, number and symbol';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Confirm Password Field
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          )!.confirmPassword,
                                          prefixIcon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),

                                      // Sign Up Button
                                      Builder(
                                        builder: (context) {
                                          final isDesktop =
                                              MediaQuery.of(
                                                context,
                                              ).size.width >
                                              600;
                                          final buttonHeight = isDesktop
                                              ? 72.0
                                              : MaterialTheme.getSpacing(
                                                  'buttonHeight',
                                                ).h;
                                          return SizedBox(
                                            height: buttonHeight,
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed:
                                                  state.requestState ==
                                                      RequestState.loading
                                                  ? null
                                                  : () {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        context.read<AuthBloc>().add(
                                                          RegisterEvent(
                                                            name:
                                                                _nameController
                                                                    .text
                                                                    .trim(),
                                                            email:
                                                                _emailController
                                                                    .text
                                                                    .trim(),
                                                            password:
                                                                _passwordController
                                                                    .text,
                                                            role: 'manager',
                                                            phone:
                                                                _phoneController
                                                                    .text
                                                                    .trim(),
                                                          ),
                                                        );
                                                      }
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFFF8A32,
                                                ),
                                                foregroundColor:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                                minimumSize: Size(
                                                  double.infinity,
                                                  buttonHeight,
                                                ),
                                                padding: EdgeInsets.zero,
                                                elevation: 4.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.0,
                                                      ),
                                                ),
                                              ),
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.signUp,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 24),

                                      // Login Link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.alreadyHaveAccount,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pushReplacementNamed(
                                                LoginScreen.route,
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.inversePrimary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                              alignment: Alignment.bottomCenter,
                                              textStyle: TextStyle(
                                                fontSize: 19.sp,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.login,
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
                        );
                      },
                    ),
                  ),
                  // Full-page loading overlay
                  if (isLoading)
                    MaterialTheme.getFullPageLoadingOverlay(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
