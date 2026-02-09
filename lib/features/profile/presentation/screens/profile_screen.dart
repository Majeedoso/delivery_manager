import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/theme/widget_decorations.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_event.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/profile/presentation/helpers/profile_formatter.dart';
import 'package:delivery_manager/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_password_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/change_email_screen.dart';
import 'package:delivery_manager/features/profile/presentation/screens/verify_email_change_otp_screen.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/countdown/presentation/controller/countdown_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  static const String route = '/profile';

  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Show loading only if we don't have user data from AuthBloc
          if (authState.user == null) {
            return Scaffold(
              body: Center(
                child: SizedBox(
                  width: 50.w,
                  height: 25.h,
                  child: Lottie.asset(
                    'assets/images/delivery_riding.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                  ),
                ),
              ),
            );
          }

          final user = authState.user!;

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.profile),
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: MaterialTheme.getGradientBackground(context),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Information (using AuthBloc data - instant)
                    _buildProfileInformation(context, user),
                    SizedBox(height: 5.h),
                    
                    // Action Buttons
                    _buildActionButtons(context, user),
                  ],
                ),
              ),
            ),
          );
        },
    );
  }

  Widget _buildActionButtons(BuildContext context, user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Edit Profile Button (includes restaurant profile for restaurant users)
        WidgetDecorations.getActionCard(
          context: context,
          title: AppLocalizations.of(context)!.editProfile,
          icon: Icons.edit,
          iconColor: Colors.deepPurple,
          onTap: () {
            Navigator.of(context).pushNamed(EditProfileScreen.route);
          },
        ),
        
        // Change Email Button
        WidgetDecorations.getActionCard(
          context: context,
          title: AppLocalizations.of(context)!.changeEmail,
          icon: Icons.email,
          iconColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.inversePrimary
              : Colors.black,
          onTap: () async {
            await _handleChangeEmailNavigation(context);
          },
        ),
        
        // Change Password Button
        WidgetDecorations.getActionCard(
          context: context,
          title: AppLocalizations.of(context)!.changePassword,
          icon: Icons.lock,
          iconColor: Colors.orange,
          onTap: () {
            Navigator.of(context).pushNamed(ChangePasswordScreen.route);
          },
        ),
        
        // Delete Account Button
        WidgetDecorations.getActionCard(
          context: context,
          title: 'Delete Account',
          icon: Icons.delete_forever,
          iconColor: Colors.red.shade700,
          onTap: () {
            _showDeleteAccountConfirmationDialog(context);
          },
        ),
        
        // Logout Button
        WidgetDecorations.getActionCard(
          context: context,
          title: AppLocalizations.of(context)!.logout,
          icon: Icons.logout,
          iconColor: Colors.red,
          onTap: () {
            _showLogoutDialog(context, context.read<AuthBloc>());
          },
        ),
      ],
    );
  }

  Widget _buildProfileInformation(BuildContext context, user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Details (using AuthBloc data - instant)
        _buildInfoCard(
          context,
          AppLocalizations.of(context)!.name,
          user.name,
          Icons.person,
        ),
        _buildInfoCard(
          context,
          AppLocalizations.of(context)!.email,
          user.email,
          Icons.email,
          isEmail: true,
        ),
        if (user.phone.isNotEmpty)
          _buildInfoCard(
            context,
            AppLocalizations.of(context)!.phone,
            user.phone,
            Icons.phone,
          ),
        _buildInfoCard(
          context,
          AppLocalizations.of(context)!.userType,
          ProfileFormatter.formatRoleName(user.role).toUpperCase(),
          Icons.category,
        ),
        _buildInfoCard(
          context,
          AppLocalizations.of(context)!.accountStatus,
          ProfileFormatter.formatStatus(user.status),
          Icons.verified,
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon, {bool isFlexible = false, bool isEmail = false}) {
    return WidgetDecorations.getInfoCard(
      context: context,
      label: label,
      value: value,
      icon: icon,
      height: isFlexible ? null : MaterialTheme.getSpacing('profileCardHeight'),
      valueTextDirection: isEmail ? TextDirection.ltr : null,
    );
  }

  Future<void> _handleChangeEmailNavigation(BuildContext context) async {
    final countdownBloc = context.read<CountdownBloc>();
    
    // Check if countdown is still active
    if (countdownBloc.state.isActive) {
      // Countdown is active, navigate directly to OTP screen
      final prefs = sl<SharedPreferences>();
      final newEmail = prefs.getString('pending_email_change');
      
      if (newEmail != null && newEmail.isNotEmpty) {
        // Navigate to OTP screen with stored newEmail
        Navigator.of(context).pushNamed(
          VerifyEmailChangeOtpScreen.route,
          arguments: {'newEmail': newEmail},
        );
      } else {
        // If newEmail is not found, go to change email screen
        Navigator.of(context).pushNamed(ChangeEmailScreen.route);
      }
    } else {
      // Countdown is not active, navigate to change email screen
      Navigator.of(context).pushNamed(ChangeEmailScreen.route);
    }
  }

  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.deleteAccount),
          content: Text(localizations.deleteAccountConfirmation),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(localizations.cancel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // Navigate to OTP verification screen
                      Navigator.of(context).pushNamed(AppRoutes.verifyDeleteAccountOtp);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(localizations.continueButton),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthBloc authBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text(AppLocalizations.of(context)!.areYouSureLogout),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
                foregroundColor: Colors.black,
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authBloc.add(LogoutEvent());
                // Navigate to login and clear navigation stack
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
  }
    );
  }
}
