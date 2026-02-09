import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/core/utils/enums.dart';

class ResetPasswordAuthenticatedScreen extends StatefulWidget {
  static const String route = '/reset-password-authenticated';

  const ResetPasswordAuthenticatedScreen({super.key});

  @override
  State<ResetPasswordAuthenticatedScreen> createState() => _ResetPasswordAuthenticatedScreenState();
}

class _ResetPasswordAuthenticatedScreenState extends State<ResetPasswordAuthenticatedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final SmartAuth _smartAuth = SmartAuth.instance;
  bool _isLoading = false;
  bool _isProcessing = false; // Guard to prevent multiple simultaneous calls
  String? _lastDetectedOtp;
  String? _initialClipboardOtp;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _otpVerified = false; // Track if OTP has been verified

  @override
  void initState() {
    super.initState();
    _lastDetectedOtp = null;
    
    // Automatically send OTP when screen first opens (if countdown is not active)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final countdownBloc = context.read<CountdownBloc>();
      if (!countdownBloc.state.isActive) {
        _resendOtp();
      }
    });
    
    _captureInitialClipboard();
    _listenForSms();
    _checkClipboardPeriodically();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      final res = await _smartAuth.getSmsWithRetrieverApi();
      logger.debug('🔍 Smart Auth: SMS Retriever result: ${res.hasData}');
      
      if (res.hasData) {
        final code = res.requireData.code;
        logger.debug('🔍 Smart Auth: Detected code: $code');
        if (code != null && code.length == 6) {
          _otpController.text = code;
          logger.info('✅ Smart Auth: OTP auto-filled: $code');
          // Wait a bit longer to ensure onCompleted doesn't also trigger
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_isProcessing) {
              if (!_otpVerified) {
                _verifyOtp();
              }
            }
          });
        }
      } else {
        logger.debug('❌ Smart Auth: No SMS detected');
      }
    } catch (e) {
      logger.warning('❌ Smart Auth: SMS Retriever API not available', e);
    }
  }

  Future<void> _checkClipboardPeriodically() async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Continue checking clipboard even during loading, but skip verification if already processing
      if (_isLoading || _isProcessing) {
        return;
      }
      
      try {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        if (clipboardData?.text != null) {
          final text = clipboardData!.text!;
          final otpRegex = RegExp(r'\b\d{6}\b');
          final match = otpRegex.firstMatch(text);
          
          if (match != null) {
            final otp = match.group(0)!;
            final isNewOtp = _lastDetectedOtp != otp;
            final isNotInField = _otpController.text != otp;
            final isNotInitialOtp = _initialClipboardOtp != otp;
            
            if (isNewOtp && isNotInField && isNotInitialOtp) {
              _lastDetectedOtp = otp;
              final logger = sl<LoggingService>();
              logger.info('✅ Auto-detected NEW OTP: $otp');
              _otpController.text = otp;
              // Don't show message, just auto-confirm silently
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !_isProcessing && !_otpVerified) {
                  _verifyOtp();
                }
              });
            }
          }
        }
      } catch (e) {
        final logger = sl<LoggingService>();
        logger.error('❌ Error checking clipboard', error: e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get user email from AuthBloc
    final authBloc = context.read<AuthBloc>();
    final userEmail = authBloc.state.user?.email ?? '';

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
          // Stop countdown
          context.read<CountdownBloc>().add(const StopCountdownEvent());
          
          if (mounted) {
            ErrorSnackBar.showSuccess(context, state.message);
            // Navigate to profile page
            Navigator.of(context).pushNamed(AppRoutes.profile);
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
            _isProcessing = state.requestState == RequestState.loading;
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
                        child: SafeArea(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(4.w),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                            SizedBox(height: 4.h),
                          Icon(
                            Icons.lock_reset,
                            size: 20.w,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            AppLocalizations.of(context)!.enterOtp,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${AppLocalizations.of(context)!.otpSentTo} $userEmail',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),
                          // OTP Input (shown first)
                          if (!_otpVerified) ...[
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Pinput(
                              length: 6,
                              controller: _otpController,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                              showCursor: true,
                              onCompleted: (pin) {
                                // Only call if not already processing (prevents duplicate calls from auto-detection)
                                if (!_isProcessing) {
                                  _verifyOtp();
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 4.h),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              final isLoading = authState.requestState == RequestState.loading;
                              return SizedBox(
                                height: MaterialTheme.getSpacing('buttonHeight').h,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (isLoading || _isProcessing) ? null : _verifyOtp,
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
                          // Password fields (shown after OTP verification)
                          if (_otpVerified) ...[
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: _obscureNewPassword,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.newPassword,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.newPasswordRequired;
                            }
                            if (value.length < 8) {
                              return AppLocalizations.of(context)!.passwordMinLength8;
                            }
                            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
                              return AppLocalizations.of(context)!.passwordComplexity;
                            }
                            return null;
                          },
                            ),
                            SizedBox(height: 4.h),
                            // Confirm Password Field
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.confirmNewPassword,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseConfirmNewPassword;
                            }
                            if (value != _newPasswordController.text) {
                              return AppLocalizations.of(context)!.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                            SizedBox(height: 4.h),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                                final isLoading = authState.requestState == RequestState.loading;
                                return SizedBox(
                                  height: MaterialTheme.getSpacing('buttonHeight').h,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: (isLoading || _isProcessing) ? null : _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, MaterialTheme.getSpacing('buttonHeight').h),
                                      padding: EdgeInsets.zero,
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: MaterialTheme.getBorderRadiusButton(),
                                      ),
                                    ),
                                    child: Text(AppLocalizations.of(context)!.resetPassword),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
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
    if (_otpController.text.length != 6) {
      final localizations = AppLocalizations.of(context)!;
      ErrorSnackBar.show(context, localizations.pleaseEnterValid6DigitOtp);
      return;
    }
    
    // Prevent multiple simultaneous calls
    if (_isProcessing) {
      final logger = sl<LoggingService>();
      logger.debug('_verifyOtp already in progress, skipping...');
      return;
    }
    
    context.read<AuthBloc>().add(VerifyPasswordResetOtpAuthenticatedEvent(
      otp: _otpController.text,
    ));
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Prevent multiple simultaneous calls
    if (_isProcessing) {
      final logger = sl<LoggingService>();
      logger.debug('_resetPassword already in progress, skipping...');
      return;
    }
    
    context.read<AuthBloc>().add(ResetPasswordAuthenticatedEvent(
      otp: _otpController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    ));
  }

  Future<void> _resendOtp() async {
    context.read<AuthBloc>().add(const SendPasswordResetOtpAuthenticatedEvent());
  }
}

