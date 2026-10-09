import 'package:flutter/material.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/core/services/public_settings_service.dart';

class ChangeEmailScreen extends StatefulWidget {
  static const String route = '/change-email';

  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changeEmail),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) async {
            if (state.requestState == RequestState.error) {
              ErrorSnackBar.show(context, state.message);
            } else if (state.requestState == RequestState.loaded && state.message.isNotEmpty) {
              // Start countdown timer (persists across navigation)
              final countdownBloc = context.read<CountdownBloc>();
              if (!countdownBloc.state.isActive) {
                // The wait set on the server (settings); a resend answer updates it
                countdownBloc.add(
                  StartCountdownEvent(
                    sl<PublicSettingsService>().otpResendWaitSeconds,
                  ),
                );
              }
              
              // Store newEmail in SharedPreferences for later retrieval
              final newEmail = _newEmailController.text.trim();
              final prefs = sl<SharedPreferences>();
              await prefs.setString('pending_email_change', newEmail);
              if (!context.mounted) return;
              
              // Navigate to OTP verification screen
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.verifyEmailChangeOtp,
                // The password is needed again to resend the code
                arguments: {
                  'newEmail': newEmail,
                  'currentPassword': _currentPasswordController.text,
                },
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.requestState == RequestState.loading;
            return Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 400,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // New Email Field
                            TextFormField(
                              controller: _newEmailController,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.newEmailAddress,
                                prefixIcon: const Icon(Icons.email),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                // The address sent is trimmed: check that one
                                final email = value?.trim() ?? '';
                                if (email.isEmpty) {
                                  return AppLocalizations.of(context)!.pleaseEnterEmail;
                                }
                                if (!RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
                                  return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                                }
                                // This page's bloc never loads the profile:
                                // the signed-in user's email is the current one
                                final current = state.profile?.email ??
                                    context.read<AuthBloc>().state.user?.email;
                                if (current != null && email.toLowerCase() == current.toLowerCase()) {
                                  return AppLocalizations.of(context)!.newEmailMustBeDifferent;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 4.h),

                            // Current Password Field (only for non-Google users)
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                                final isGoogleUser = authState.user?.googleId != null;
                                
                                if (isGoogleUser) {
                                  return const SizedBox.shrink();
                                }
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextFormField(
                                      controller: _currentPasswordController,
                                      obscureText: _obscurePassword,
                                      textDirection: TextDirection.ltr,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!.currentPassword,
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context)!.pleaseEnterPassword;
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 4.h),
                                  ],
                                );
                              },
                            ),

                            // Change Email Button
                            Builder(
                              builder: (context) {
                                final isDesktop = MediaQuery.of(context).size.width > 600;
                                final buttonHeight = isDesktop ? 72.0 : MaterialTheme.getSpacing('buttonHeight').h;
                                return SizedBox(
                                  height: buttonHeight,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _changeEmail,
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
                                    child: Text(AppLocalizations.of(context)!.changeEmail),
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
                if (isLoading)
                  MaterialTheme.getFullPageLoadingOverlay(context),
              ],
            );
          },
        ),
      ),
    );
  }

  void _changeEmail() {
    if (_formKey.currentState!.validate()) {
      // Get current user to check if they're a Google user
      final authState = context.read<AuthBloc>().state;
      final isGoogleUser = authState.user?.googleId != null;
      
      context.read<ProfileBloc>().add(ChangeEmailEvent(
            newEmail: _newEmailController.text.trim(),
            currentPassword: isGoogleUser ? '' : _currentPasswordController.text,
          ));
    }
  }
}
