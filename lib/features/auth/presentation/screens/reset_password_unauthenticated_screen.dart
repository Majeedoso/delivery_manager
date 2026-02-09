import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:sizer/sizer.dart';

class ResetPasswordUnauthenticatedScreen extends StatefulWidget {
  static const String route = '/reset-password-unauthenticated';
  final String email;
  final String otp;
  
  const ResetPasswordUnauthenticatedScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordUnauthenticatedScreen> createState() => _ResetPasswordUnauthenticatedScreenState();
}

class _ResetPasswordUnauthenticatedScreenState extends State<ResetPasswordUnauthenticatedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final SmartAuth _smartAuth = SmartAuth.instance;
  bool _isLoading = false;
  bool _otpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _lastDetectedOtp;
  String? _initialClipboardOtp;

  @override
  void initState() {
    super.initState();
    _lastDetectedOtp = null;
    _captureInitialClipboard();
    _listenForSms();
    _checkClipboardPeriodically();
  }

  Future<void> _captureInitialClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!;
        final otpRegex = RegExp(r'\b\d{6}\b');
        final match = otpRegex.firstMatch(text);
        if (match != null) {
          _initialClipboardOtp = match.group(0)!;
          final logger = sl<LoggingService>();
          logger.debug('📋 Initial clipboard OTP captured: $_initialClipboardOtp');
        }
      }
    } catch (e) {
      final logger = sl<LoggingService>();
      logger.error('❌ Error capturing initial clipboard', error: e);
    }
  }

  Future<void> _listenForSms() async {
    final logger = sl<LoggingService>();
    try {
      logger.debug('🔍 Smart Auth: Starting SMS detection...');
      // Try SMS Retriever API first (no user consent needed)
      final res = await _smartAuth.getSmsWithRetrieverApi();
      logger.debug('🔍 Smart Auth: SMS Retriever result: ${res.hasData}');
      
      if (res.hasData) {
        final code = res.requireData.code;
        logger.debug('🔍 Smart Auth: Detected code: $code');
        if (code != null && code.length == 6) {
          // Set the OTP in Pinput controller
          _otpController.text = code;
          logger.info('✅ Smart Auth: OTP auto-filled: $code');
          // Auto-verify OTP when detected
          Future.delayed(const Duration(milliseconds: 500), () {
            _verifyOtp();
          });
        }
      } else {
        logger.debug('❌ Smart Auth: No SMS detected');
      }
    } catch (e) {
      // SMS Retriever API might not work, that's okay
      logger.warning('❌ Smart Auth: SMS Retriever API not available', e);
    }
  }


  Future<void> _checkClipboardPeriodically() async {
    // Check clipboard every 1 second for OTP
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted || _otpVerified) {
        timer.cancel();
        return;
      }
      
      // Continue checking clipboard even during loading, but skip verification if already processing
      if (_isLoading) {
        return;
      }
      
      try {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (clipboardData?.text != null) {
          final text = clipboardData!.text!;
          
          // Look for 6-digit OTP in clipboard
          final otpRegex = RegExp(r'\b\d{6}\b');
          final match = otpRegex.firstMatch(text);
          
          if (match != null) {
            final otp = match.group(0)!;
            
            // Only process if:
            // 1. It's a new OTP (different from last detected)
            // 2. It's not already in the input field
            // 3. It's not the initial clipboard OTP (old OTP that was there when screen opened)
            final isNewOtp = _lastDetectedOtp != otp;
            final isNotInField = _otpController.text != otp;
            final isNotInitialOtp = _initialClipboardOtp != otp;
            
            if (isNewOtp && isNotInField && isNotInitialOtp) {
              _lastDetectedOtp = otp;
              final logger = sl<LoggingService>();
              logger.info('✅ Auto-detected NEW OTP: $otp');
              _otpController.text = otp;
              // Don't show message, just auto-verify silently
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _verifyOtp();
                }
              });
            } else if (isNewOtp && isNotInField && !isNotInitialOtp) {
              final logger = sl<LoggingService>();
              logger.debug('⚠️ Ignoring initial clipboard OTP: $otp');
            }
          }
        }
      } catch (e) {
        // Ignore clipboard errors
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // Clean up Smart Auth listeners
    _smartAuth.removeUserConsentApiListener();
    _smartAuth.removeSmsRetrieverApiListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle OTP verification success
        if (state.requestState == RequestState.loaded && 
            state.message.contains('OTP verified successfully')) {
          setState(() => _otpVerified = true);
          if (mounted) {
            ErrorSnackBar.showSuccess(context, state.message);
          }
        }
        
        // Handle password reset success
        if (state.requestState == RequestState.loaded && 
            state.message.contains('Password reset successfully')) {
          if (mounted) {
            ErrorSnackBar.showSuccess(context, state.message);
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
          }
        }
        
        // Handle resend OTP success
        if (state.requestState == RequestState.loaded && 
            state.message.contains('Password reset OTP sent') &&
            state.resendCountdown != null) {
          // Start countdown
          final countdownBloc = context.read<CountdownBloc>();
          final countdownValue = state.resendCountdown ?? 120;
          if (!countdownBloc.state.isActive) {
            countdownBloc.add(StartCountdownEvent(countdownValue));
          }
          if (mounted) {
            ErrorSnackBar.showSuccess(context, state.message);
          }
        }
        
        // Handle errors
        if (state.requestState == RequestState.error && state.message.isNotEmpty) {
          if (mounted) {
            ErrorSnackBar.show(context, state.message);
          }
        }
        
        // Update loading state
        if (mounted) {
          setState(() {
            _isLoading = state.requestState == RequestState.loading;
          });
        }
      },
      child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.resetPassword),
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isLoading = authState.requestState == RequestState.loading;
                return Stack(
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
                Icons.security,
                size: 25.w,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFFF8A32)
                    : Colors.black,
              ),
              const SizedBox(height: 24),
              Text(
                _otpVerified ? AppLocalizations.of(context)!.setNewPassword : AppLocalizations.of(context)!.enterOtpCode,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
                Text(
                  _otpVerified 
                    ? AppLocalizations.of(context)!.enterNewPasswordDescription
                    : AppLocalizations.of(context)!.enterOtpDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // OTP Input with Pinput (shown first)
              if (!_otpVerified) ...[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Builder(
                    builder: (context) {
                      final defaultPinTheme = PinTheme(
                        width: 12.w,
                        height: 12.w,
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      );

                      final focusedPinTheme = defaultPinTheme.copyDecorationWith(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          width: 2,
                        ),
                      );

                      final submittedPinTheme = defaultPinTheme.copyDecorationWith(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      );

                      return Pinput(
                        length: 6,
                        controller: _otpController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        onCompleted: (pin) {
                          // Auto-verify OTP when completed
                          _verifyOtp();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Verify OTP Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final isLoading = authState.requestState == RequestState.loading;
                    return SizedBox(
                      height: MaterialTheme.getSpacing('buttonHeight').h,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (isLoading || _otpController.text.length != 6) ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A32),
                          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          minimumSize: Size(double.infinity, MaterialTheme.getSpacing('buttonHeight').h),
                          padding: EdgeInsets.zero,
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.verifyOtp),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Password fields (shown after OTP verification)
              if (_otpVerified) ...[
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.newPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.confirmNewPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              // Only show Reset Password button when OTP is verified
              if (_otpVerified) ...[
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final isLoading = authState.requestState == RequestState.loading;
                    final isDesktop = MediaQuery.of(context).size.width > 600;
                    final buttonHeight = isDesktop ? 72.0 : MaterialTheme.getSpacing('buttonHeight').h;
                    return SizedBox(
                      height: buttonHeight,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A32),
                          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          minimumSize: Size(double.infinity, buttonHeight),
                          padding: EdgeInsets.zero,
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.resetPassword),
                      ),
                    );
                  },
                ),
              ],
                // Resend OTP button (only show when OTP is not verified)
                if (!_otpVerified) ...[
                  const SizedBox(height: 16),
                  BlocBuilder<CountdownBloc, CountdownState>(
                    builder: (context, countdownState) {
                      final countdownSeconds = countdownState.countdownSeconds;
                      final isCountdownActive = countdownState.isActive;
                      
                      // Always show the button enabled, but prevent sending if countdown is active
                      return BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final isLoading = authState.requestState == RequestState.loading;
                          final isDesktop = MediaQuery.of(context).size.width > 600;
                          final buttonHeight = isDesktop ? 72.0 : MaterialTheme.getSpacing('buttonHeight').h;
                          return SizedBox(
                            height: buttonHeight,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () {
                                // Only send OTP if countdown is not active
                                if (!isCountdownActive) {
                                  _resendOtp();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: isCountdownActive 
                                    ? Colors.grey 
                                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                minimumSize: Size(double.infinity, buttonHeight),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(isCountdownActive 
                                  ? AppLocalizations.of(context)!.resendIn(countdownSeconds)
                                  : AppLocalizations.of(context)!.resendOtp),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
                    ],
                  ),
                ),
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
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;
    
    // Dispatch event to AuthBloc
    context.read<AuthBloc>().add(VerifyPasswordResetOtpEvent(
      email: widget.email,
      otp: _otpController.text,
    ));
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Dispatch event to AuthBloc
    context.read<AuthBloc>().add(ResetPasswordEvent(
      email: widget.email,
      otp: _otpController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    ));
  }

  Future<void> _resendOtp() async {
    // Dispatch event to AuthBloc
    context.read<AuthBloc>().add(ResendPasswordResetOtpEvent(
      email: widget.email,
    ));
  }

}

