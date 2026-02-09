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
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/features/home/presentation/screens/main_screen.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';

class VerifyEmailOtpScreen extends StatefulWidget {
  static const String route = '/verify-email-otp';
  final String email;

  const VerifyEmailOtpScreen({super.key, required this.email});

  @override
  State<VerifyEmailOtpScreen> createState() => _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends State<VerifyEmailOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final SmartAuth _smartAuth = SmartAuth.instance;
  bool _isLoading = false;
  bool _isProcessing = false; // Guard to prevent multiple simultaneous calls
  String? _lastDetectedOtp;
  String? _initialClipboardOtp;

  @override
  void initState() {
    super.initState();
    _lastDetectedOtp = null;

    // Start countdown if not already active (persists across navigation)
    final countdownBloc = context.read<CountdownBloc>();
    if (!countdownBloc.state.isActive) {
      // Default to 120 seconds (2 minutes) - will be updated by resend response
      countdownBloc.add(const StartCountdownEvent(120));
    }

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
          logger.debug(
            '📋 Initial clipboard OTP captured: $_initialClipboardOtp',
          );
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
              _verifyEmail();
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
              // Don't show message, just auto-verify silently
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !_isProcessing) {
                  _verifyEmail();
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
      border: Border.all(color: Colors.green, width: 2),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.verifyEmail),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Create Account page (SignupChoiceScreen)
            Navigator.of(context).pushReplacementNamed(AppRoutes.signupChoice);
          },
        ),
      ),
      body: Stack(
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
                        Icons.email,
                        size: 20.w,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        AppLocalizations.of(context)!.enterOtp,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${AppLocalizations.of(context)!.otpSentTo} ${widget.email}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18.sp,
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
                          pinputAutovalidateMode:
                              PinputAutovalidateMode.onSubmit,
                          showCursor: true,
                          onCompleted: (pin) {
                            // Only call if not already processing (prevents duplicate calls from auto-detection)
                            if (!_isProcessing) {
                              _verifyEmail();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        height: MaterialTheme.getSpacing('buttonHeight').h,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isProcessing)
                              ? null
                              : _verifyEmail,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                              double.infinity,
                              MaterialTheme.getSpacing('buttonHeight').h,
                            ),
                            padding: EdgeInsets.zero,
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  MaterialTheme.getBorderRadiusButton(),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.verifyOtp),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      BlocBuilder<CountdownBloc, CountdownState>(
                        builder: (context, countdownState) {
                          final remainingSeconds =
                              countdownState.countdownSeconds;
                          final canResend = !countdownState.isActive;
                          final isDesktop =
                              MediaQuery.of(context).size.width > 600;
                          final buttonHeight = isDesktop
                              ? 72.0
                              : MaterialTheme.getSpacing('buttonHeight').h;

                          return SizedBox(
                            height: buttonHeight,
                            width: double.infinity,
                            child: TextButton(
                              onPressed: canResend && !_isLoading
                                  ? _resendOtp
                                  : null,
                              style: TextButton.styleFrom(
                                minimumSize: Size(
                                  double.infinity,
                                  buttonHeight,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                canResend
                                    ? AppLocalizations.of(context)!.resendOtp
                                    : '${AppLocalizations.of(context)!.resendOtp} (${remainingSeconds}s)',
                                style: TextStyle(
                                  color: canResend
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Full-page loading overlay
          if (_isLoading) MaterialTheme.getFullPageLoadingOverlay(context),
        ],
      ),
    );
  }

  Future<void> _verifyEmail() async {
    if (_otpController.text.length != 6) return;

    // Prevent multiple simultaneous calls
    if (_isProcessing) {
      final logger = sl<LoggingService>();
      logger.debug('_verifyEmail already in progress, skipping...');
      return;
    }

    _isProcessing = true;
    setState(() => _isLoading = true);

    try {
      final dio = sl<Dio>();
      final response = await dio.post(
        ApiConstance.verifyEmailOtpPath,
        data: {'email': widget.email, 'otp': _otpController.text},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Get current user to preserve token
        final currentUserResult = await sl<BaseAuthLocalDataSource>()
            .getCurrentUser();
        String? token;
        if (currentUserResult != null) {
          token = currentUserResult.token;
        }

        // Parse response - backend returns minimal data, so we need to get full user
        final data = response.data['data'] ?? {};
        final userData = {
          'id': currentUserResult?.id ?? 0,
          'name': currentUserResult?.name ?? '',
          'email': data['email'] ?? widget.email,
          'phone': currentUserResult?.phone ?? '',
          'role': currentUserResult?.role.toString() ?? 'driver',
          'email_verified_at': data['email_verified_at'],
          'has_password': currentUserResult?.hasPassword ?? false,
        };
        if (token != null) {
          userData['token'] = token;
        }

        final user = UserModel.fromJson(userData);

        // Save updated user
        await sl<BaseAuthLocalDataSource>().saveUser(user);

        // Update AuthBloc state
        context.read<AuthBloc>().add(CheckAuthStatusEvent());

        // Stop countdown
        context.read<CountdownBloc>().add(const StopCountdownEvent());

        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ErrorSnackBar.showSuccess(
            context,
            response.data['message'] ?? localizations.emailVerifiedSuccessfully,
          );

          // Navigate to main screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(MainScreen.route, (route) => false);
        }
      } else {
        final localizations = AppLocalizations.of(context)!;
        throw Exception(
          response.data['message'] ?? localizations.failedToVerifyEmailOtp,
        );
      }
    } on DioException catch (e) {
      final localizations = AppLocalizations.of(context)!;
      String errorMessage = localizations.failedToVerifyEmailOtp;
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = localizations.requestTimeoutCheckConnection;
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = localizations.cannotConnectToServer;
      }

      if (mounted) {
        ErrorSnackBar.show(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, e);
      }
    } finally {
      if (mounted) {
        _isProcessing = false;
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);

    try {
      final dio = sl<Dio>();
      final response = await dio.post(
        ApiConstance.resendVerificationEmailPath,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? {};
        final resendCountdown = data['resend_countdown'] as int? ?? 120;

        // Start countdown
        final countdownBloc = context.read<CountdownBloc>();
        if (!countdownBloc.state.isActive) {
          countdownBloc.add(StartCountdownEvent(resendCountdown));
        }

        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ErrorSnackBar.showSuccess(
            context,
            localizations.verificationOtpSentSuccessfully,
          );
        }
      } else {
        final localizations = AppLocalizations.of(context)!;
        throw Exception(
          response.data['message'] ??
              localizations.failedToResendVerificationOtp,
        );
      }
    } on DioException catch (e) {
      final localizations = AppLocalizations.of(context)!;
      String errorMessage = localizations.failedToResendVerificationOtp;
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      if (mounted) {
        ErrorSnackBar.show(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
