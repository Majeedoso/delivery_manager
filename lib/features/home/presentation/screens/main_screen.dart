import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_bloc.dart';
import 'package:delivery_manager/features/auth/presentation/controller/auth_state.dart';
import 'package:delivery_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const String route = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.requestState == RequestState.loaded &&
            !state.isAuthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
        } else if (state.requestState == RequestState.error) {
          ErrorSnackBar.show(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.appName)),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: MaterialTheme.getGradientBackground(context),
            child: _buildMainContent(context, state),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, AuthState state) {
    if (state.user == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noUserDataAvailable,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: MaterialTheme.getPaddingLarge(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Action Buttons
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: MaterialTheme.getSpacing('spacingGrid').w,
                    runSpacing: MaterialTheme.getSpacing('spacingGrid').w * 3,
                    children: [
                      // Bank Container
                      _buildBankContainer(context),

                      // Profile Container
                      _buildProfileContainer(context),

                      // Settings Container
                      _buildSettingsContainer(context),

                      // About Container
                      _buildAboutContainer(context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContainer(BuildContext context) {
    return _buildIconContainer(
      context,
      title: AppLocalizations.of(context)!.profile,
      iconPath: 'assets/images/profile.ico',
      onTap: () => _navigateToProfile(context),
    );
  }

  Widget _buildSettingsContainer(BuildContext context) {
    return _buildIconContainer(
      context,
      title: AppLocalizations.of(context)!.settings,
      iconPath: 'assets/images/settings.ico',
      onTap: () => _navigateToSettings(context),
    );
  }

  Widget _buildAboutContainer(BuildContext context) {
    return _buildIconContainer(
      context,
      title: AppLocalizations.of(context)!.aboutApp,
      iconPath: 'assets/images/info.ico',
      onTap: () => _navigateToAbout(context),
    );
  }

  Widget _buildIconContainer(
    BuildContext context, {
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MaterialTheme.getSpacing('containerWidthLarge').w,
      height: MaterialTheme.getSpacing('containerWidthLarge').w,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: MaterialTheme.getBorderRadiusButton(),
        ),
        child: InkWell(
          borderRadius: MaterialTheme.getBorderRadiusButton(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fixed height for icon area to ensure alignment
                SizedBox(
                  height:
                      MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
                  child: Center(child: _buildIcon(context, iconPath)),
                ),
                SizedBox(height: 0.1.h),
                // Fixed height for text area to ensure first line alignment
                Flexible(
                  child: SizedBox(
                    height:
                        Theme.of(context).textTheme.titleMedium?.fontSize !=
                            null
                        ? Theme.of(context).textTheme.titleMedium!.fontSize! *
                              2.8
                        : 48,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/profile');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.of(context).pushNamed('/about');
  }

  Widget _buildBankContainer(BuildContext context) {
    return _buildIconContainer(
      context,
      title: AppLocalizations.of(context)!.bank,
      iconPath: 'assets/images/bank.ico',
      onTap: () => _navigateToBank(context),
    );
  }

  void _navigateToBank(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.bank);
  }

  Widget _buildIcon(BuildContext context, String iconPath) {
    return Image.asset(
      iconPath,
      width: MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
      height: MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to Material icon if asset is missing
        return Icon(
          Icons.error_outline,
          size: MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
          color: Theme.of(context).colorScheme.onSurface,
        );
      },
    );
  }
}
