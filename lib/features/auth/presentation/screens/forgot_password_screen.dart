import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String route = '/forgot-password';
  
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Don't stop countdown - it should persist across navigation
    // This prevents bypassing rate limiting by going back and forth
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle countdown when password reset OTP is sent
        if (state.requestState == RequestState.loaded && 
            state.message.contains('Password reset OTP sent') &&
            state.resendCountdown != null) {
          // Start countdown with the value from the backend response
          final countdownBloc = context.read<CountdownBloc>();
          final countdownValue = state.resendCountdown ?? 120; // Default to 120 if not provided
          if (!countdownBloc.state.isActive) {
            countdownBloc.add(StartCountdownEvent(countdownValue));
          }
          if (mounted) {
            ErrorSnackBar.showSuccess(context, state.message);
            
            // Navigate to reset password screen with email
            Navigator.pushNamed(
              context, 
              AppRoutes.resetPasswordUnauthenticated,
              arguments: {
                'email': _emailController.text.trim(),
                'otp': '', // Will be filled by user
              }
            );
          }
        }
        
        // Show error messages
        if (state.message.isNotEmpty && state.requestState == RequestState.error) {
          if (mounted) {
            ErrorSnackBar.show(context, state.message);
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isLoading = authState.requestState == RequestState.loading;
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.forgotPassword),
            ),
            body: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: MaterialTheme.getGradientBackground(context),
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const SizedBox(height: 32),
                    Icon(
                      Icons.lock_reset,
                      size: 25.w,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFFF8A32)
                          : Colors.black,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.resetYourPassword,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.enterEmailDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.emailAddress,
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<CountdownBloc, CountdownState>(
                      builder: (context, countdownState) {
                        // Check countdown state directly (persists across navigation)
                        final isCountdownActive = countdownState.isActive;
                        final countdownSeconds = countdownState.countdownSeconds;
                        
                        // Button is always enabled
                        // If countdown is active: navigate to OTP page without sending new OTP
                        // If countdown is not active: send OTP and navigate
                        final isDesktop = MediaQuery.of(context).size.width > 600;
                        final buttonHeight = isDesktop ? 72.0 : MaterialTheme.getSpacing('buttonHeight').h;
                        return SizedBox(
                          height: buttonHeight,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () {
                              if (isCountdownActive) {
                                // Countdown is active - just navigate to OTP page without sending new OTP
                                Navigator.pushNamed(
                                  context, 
                                  AppRoutes.resetPasswordUnauthenticated,
                                  arguments: {
                                    'email': _emailController.text.trim(),
                                    'otp': '', // Will be filled by user
                                  }
                                );
                              } else {
                                // Countdown is not active - send OTP (will navigate in listener)
                                _sendResetEmail();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCountdownActive ? Colors.grey : const Color(0xFFFF8A32),
                              foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              minimumSize: Size(double.infinity, buttonHeight),
                              padding: EdgeInsets.zero,
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Text(isCountdownActive 
                                ? AppLocalizations.of(context)!.resendIn(countdownSeconds)
                                : AppLocalizations.of(context)!.sendOtp),
                          ),
                        );
                      },
                    ),
                    ],
                  ),
                ),
              ),
            ),
                // Full-page loading overlay
                if (isLoading)
                  MaterialTheme.getFullPageLoadingOverlay(context),
              ],
            ),
          );
        },
      ),
    );
  }

  void _sendResetEmail() {
    if (!_formKey.currentState!.validate()) return;
    
    // Use AuthBloc to send password reset OTP
    context.read<AuthBloc>().add(ResendPasswordResetOtpEvent(
      email: _emailController.text.trim(),
    ));
  }

}
