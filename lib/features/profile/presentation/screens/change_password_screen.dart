import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_bloc.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_event.dart';
import 'package:delivery_manager/features/profile/presentation/controller/profile_state.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String route = '/change-password';

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changePassword),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.requestState == RequestState.error) {
              ErrorSnackBar.show(context, state.message);
            } else if (state.requestState == RequestState.loaded && state.message.isNotEmpty) {
              ErrorSnackBar.showSuccess(context, state.message);
              Navigator.of(context).pop();
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
                        // Current Password Field (only if user has a password)
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            final hasPassword = authState.user?.hasPassword ?? false;
                            
                            if (!hasPassword) {
                              return const SizedBox.shrink();
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextFormField(
                                  controller: _currentPasswordController,
                                  obscureText: _obscureCurrentPassword,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.currentPassword,
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureCurrentPassword = !_obscureCurrentPassword;
                                        });
                                      },
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!.currentPasswordRequired;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Forgot Password Link
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.resetPasswordAuthenticated,
                                      );
                                    },
                                    child: Text(AppLocalizations.of(context)!.forgotPassword),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                              ],
                            );
                          },
                        ),

                        // New Password Field
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
                        SizedBox(height: 6.h),

                        // Change Password Button
                        Builder(
                          builder: (context) {
                            final isDesktop = MediaQuery.of(context).size.width > 600;
                            final buttonHeight = isDesktop ? 72.0 : MaterialTheme.getSpacing('buttonHeight').h;
                            return SizedBox(
                              height: buttonHeight,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _changePassword,
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
                                child: Text(AppLocalizations.of(context)!.changePassword),
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

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // Get current user to check if they have a password
      final authState = context.read<AuthBloc>().state;
      final hasPassword = authState.user?.hasPassword ?? false;
      
      context.read<ProfileBloc>().add(ChangePasswordEvent(
            currentPassword: hasPassword ? _currentPasswordController.text : '',
            newPassword: _newPasswordController.text,
            newPasswordConfirmation: _confirmPasswordController.text,
          ));
    }
  }
}
