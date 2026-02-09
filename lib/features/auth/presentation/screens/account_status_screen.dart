import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_state.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class AccountStatusScreen extends StatelessWidget {
  const AccountStatusScreen({super.key});

  static const String route = '/account-status';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.route);
            },
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: localizations?.settings ?? 'Settings',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // Listen for status changes and messages
            if (state.requestState == RequestState.loaded &&
                state.user != null) {
              final user = state.user!;

              // If user is now approved and email is verified, navigate to splash screen
              // to start fresh and run the normal initialization flow
              if (user.isApproved && user.hasVerifiedEmail) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
              }
            }

            // Handle navigation to OTP screen when verification email is sent
            if (state.requestState == RequestState.loaded &&
                state.message == 'verificationEmailSent' &&
                state.user != null) {
              // Start countdown with the value from the backend response
              final countdownBloc = context.read<CountdownBloc>();
              final countdownValue =
                  state.resendCountdown ??
                  120; // Default to 120 if not provided
              if (!countdownBloc.state.isActive) {
                countdownBloc.add(StartCountdownEvent(countdownValue));
              }

              // Navigate to OTP verification screen
              final user = state.user!;
              Navigator.of(context).pushNamed(
                AppRoutes.verifyEmailOtp,
                arguments: {'email': user.email},
              );
            }

            // Show error messages
            if (state.message.isNotEmpty &&
                state.requestState == RequestState.error) {
              final localizations = AppLocalizations.of(context);
              if (localizations != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            // Show loading animation only if user is null and we're not loading (initial state)
            if (state.user == null &&
                state.requestState != RequestState.loading) {
              return Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/images/delivery_riding.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
              );
            }

            // If loading and user exists, keep showing the current user state
            // If user is null during loading, show loading overlay but keep previous UI structure
            final user = state.user;
            if (user == null) {
              // During loading with no user, show loading overlay
              return const Center(child: CircularProgressIndicator());
            }

            final localizations = AppLocalizations.of(context)!;

            // Check if email verification is required (account approved but email not verified)
            final isEmailVerificationRequired =
                user.isApproved && !user.hasVerifiedEmail;

            // Handle null status - treat as pending approval for new users
            final effectiveStatus = user.status ?? 'pending_approval';
            final isPendingApproval =
                user.isPendingApproval ||
                (user.status == null &&
                    (user.role == UserRole.operator ||
                        user.role == UserRole.restaurant ||
                        user.role == UserRole.driver ||
                        user.role == UserRole.manager));

            final isLoading = state.requestState == RequestState.loading;

            final List<Widget> stackChildren = <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status icon
                      Icon(
                        isEmailVerificationRequired
                            ? Icons.email_outlined
                            : _getStatusIcon(effectiveStatus),
                        size: 35.w,
                        color: (user.isApproved && user.hasVerifiedEmail)
                            ? Colors
                                  .green // Green for approved accounts in both light and dark mode
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? (isEmailVerificationRequired ||
                                            isPendingApproval
                                        ? const Color(0xFFFF8A32)
                                        : Colors.white)
                                  : (isEmailVerificationRequired
                                        ? const Color(0xFFFF8A32)
                                        : (isPendingApproval
                                              ? Colors.black
                                              : Colors.black87))),
                      ),
                      SizedBox(height: 2.h),

                      // Status title
                      Text(
                        isEmailVerificationRequired
                            ? localizations.emailNotVerified
                            : _getStatusTitle(effectiveStatus, context),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),

                      // Status message
                      Text(
                        isEmailVerificationRequired
                            ? localizations.emailVerificationRequired
                            : (user.isApproved && user.hasVerifiedEmail)
                            ? 'Your account has been approved! Redirecting...'
                            : _getStatusMessage(
                                effectiveStatus,
                                user.rejectionReason,
                                context,
                              ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),

                      // Additional info for rejected users
                      if (user.isRejected && user.rejectionReason != null) ...[
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Rejection Reason:',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                user.rejectionReason!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],

                      // Action buttons
                      if (isEmailVerificationRequired) ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: SizedBox(
                            width: 75.w,
                            child: BlocBuilder<CountdownBloc, CountdownState>(
                              builder: (context, countdownState) {
                                final isCountdownActive =
                                    countdownState.isActive;
                                final countdownSeconds =
                                    countdownState.countdownSeconds;

                                return ElevatedButton(
                                  onPressed:
                                      state.requestState == RequestState.loading
                                      ? null
                                      : () {
                                          if (isCountdownActive) {
                                            // Countdown is active, just navigate to OTP screen without sending new OTP
                                            final user = state.user;
                                            if (user != null) {
                                              Navigator.of(context).pushNamed(
                                                AppRoutes.verifyEmailOtp,
                                                arguments: {
                                                  'email': user.email,
                                                },
                                              );
                                            }
                                          } else {
                                            // Countdown is not active, send new OTP
                                            context.read<AuthBloc>().add(
                                              ResendVerificationEmailEvent(),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : (Theme.of(context)
                                                  .inputDecorationTheme
                                                  .fillColor ??
                                              Colors.white),
                                    foregroundColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFFFF8A32)
                                        : Colors.black,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 3.w,
                                    ),
                                    minimumSize: Size(
                                      double.infinity,
                                      22.sp + (3.w * 2) + 4,
                                    ), // Match height of other buttons (icon size + padding)
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Icon(
                                          Icons.email,
                                          size: 18.sp,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFFFF8A32)
                                              : Colors.black,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Text(
                                          isCountdownActive
                                              ? '${localizations.resendVerificationEmail} (${countdownSeconds}s)'
                                              : localizations
                                                    .resendVerificationEmail,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFFFF8A32)
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: SizedBox(
                            width: 75.w,
                            child: ElevatedButton(
                              onPressed:
                                  state.requestState == RequestState.loading
                                  ? null
                                  : () {
                                      // Check auth status and refresh user data
                                      context.read<AuthBloc>().add(
                                        CheckAuthStatusEvent(),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 3.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(Icons.refresh, size: 22.sp),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Text(
                                      localizations.checkStatus,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else if (isPendingApproval) ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: SizedBox(
                            width: 75.w,
                            child: ElevatedButton(
                              onPressed:
                                  state.requestState == RequestState.loading
                                  ? null
                                  : () {
                                      // Check auth status and refresh user data
                                      context.read<AuthBloc>().add(
                                        CheckAuthStatusEvent(),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : (Theme.of(
                                            context,
                                          ).inputDecorationTheme.fillColor ??
                                          Colors.white),
                                foregroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFFF8A32)
                                    : Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 3.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Icon(
                                      Icons.refresh,
                                      size: 22.sp,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFFFF8A32)
                                          : Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Text(
                                      localizations.checkStatus,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          localizations.checkStatusDescription,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white60
                                    : Colors.black54,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      SizedBox(height: 2.h),

                      // Logout button
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: SizedBox(
                          width: 75.w,
                          child: isEmailVerificationRequired
                              ? ElevatedButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(LogoutEvent());
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      LoginScreen.route,
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 3.w,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(LogoutEvent());
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      LoginScreen.route,
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 3.w,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
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

            return Stack(children: stackChildren);
          },
        ),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending_approval':
        return Icons.pending_actions;
      case 'suspended':
        return Icons.block;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusTitle(String? status, BuildContext context) {
    switch (status) {
      case 'pending_approval':
        return 'Account Pending Approval';
      case 'suspended':
        return 'Account Suspended';
      case 'rejected':
        return 'Account Rejected';
      default:
        return 'Account Status';
    }
  }

  String _getStatusMessage(
    String? status,
    String? rejectionReason,
    BuildContext context,
  ) {
    switch (status) {
      case 'pending_approval':
        return 'Your account is pending manager approval. Please wait for a manager to review and approve your account before you can access the system. You will be notified once your account is approved.';
      case 'suspended':
        return 'Your account has been suspended. Please contact support for assistance.';
      case 'rejected':
        return 'Your account has been rejected. Please contact support for more information.';
      case 'active':
      case 'approved':
        return 'Your account has been approved! Redirecting...';
      default:
        // For unknown statuses, default to pending approval message instead of error
        return 'Your account is pending manager approval. Please wait for a manager to review and approve your account before you can access the system.';
    }
  }
}
