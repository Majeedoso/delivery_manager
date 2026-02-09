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
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/core/utils/enums.dart';

class VerifyDeleteAccountOtpScreen extends StatefulWidget {
  static const String route = '/verify-delete-account-otp';

  const VerifyDeleteAccountOtpScreen({super.key});

  @override
  State<VerifyDeleteAccountOtpScreen> createState() => _VerifyDeleteAccountOtpScreenState();
}

class _VerifyDeleteAccountOtpScreenState extends State<VerifyDeleteAccountOtpScreen> {
  final _otpController = TextEditingController();
  final SmartAuth _smartAuth = SmartAuth.instance;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _lastDetectedOtp;
  String? _initialClipboardOtp;

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
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_isProcessing) {
              _verifyAndDelete();
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
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !_isProcessing) {
                  _verifyAndDelete();
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

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // Handle account deletion success
        if (state.requestState == RequestState.loaded &&
            state.message.contains('Account deleted successfully')) {
          // Stop countdown
          context.read<CountdownBloc>().add(const StopCountdownEvent());
          
          if (mounted) {
            ErrorSnackBar.showSuccess(context, state.message);
            // Logout and navigate to login
            context.read<AuthBloc>().add(LogoutEvent());
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          }
        }

        // Handle resend OTP success
        if (state.requestState == RequestState.loaded &&
            state.message.contains('Account deletion OTP sent') &&
            state.resendCountdown != null) {
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
          title: const Text('Delete Account'),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final isLoading = profileState.requestState == RequestState.loading;
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: MaterialTheme.getGradientBackground(context),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 4.h),
                          Icon(
                            Icons.delete_forever,
                            size: 20.w,
                            color: Colors.red.shade700,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Enter Verification Code',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'We sent a verification code to $userEmail',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Please enter the code to confirm account deletion. This action cannot be undone.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),
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
                                if (!_isProcessing) {
                                  _verifyAndDelete();
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 4.h),
                          BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              final isLoading = state.requestState == RequestState.loading;
                              return SizedBox(
                                height: MaterialTheme.getSpacing('buttonHeight').h,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (isLoading || _isProcessing) ? null : _verifyAndDelete,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, MaterialTheme.getSpacing('buttonHeight').h),
                                    padding: EdgeInsets.zero,
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: const Text('Delete Account'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<CountdownBloc, CountdownState>(
                            builder: (context, countdownState) {
                              final countdownSeconds = countdownState.countdownSeconds;
                              final isCountdownActive = countdownState.isActive;
                              
                              return BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, state) {
                                  final isLoading = state.requestState == RequestState.loading;
                                  final isDesktop = MediaQuery.of(context).size.width > 600;
                                  final buttonHeight = isDesktop ? 72.0 : MaterialTheme.getSpacing('buttonHeight').h;
                                  return SizedBox(
                                    height: buttonHeight,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : () {
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
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  MaterialTheme.getFullPageLoadingOverlay(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _verifyAndDelete() async {
    if (_otpController.text.length != 6) {
      final localizations = AppLocalizations.of(context)!;
      ErrorSnackBar.show(context, localizations.pleaseEnterValid6DigitOtp);
      return;
    }
    
    if (_isProcessing) {
      final logger = sl<LoggingService>();
      logger.debug('_verifyAndDelete already in progress, skipping...');
      return;
    }
    
    context.read<ProfileBloc>().add(VerifyDeleteAccountOtpEvent(
      otp: _otpController.text,
    ));
  }

  Future<void> _resendOtp() async {
    context.read<ProfileBloc>().add(const SendDeleteAccountOtpEvent());
  }
}

