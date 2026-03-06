import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_contact_info_usecase.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';

class AboutScreen extends StatefulWidget {
  static const String route = '/about';

  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _email;
  String? _phone;
  String? _website;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    try {
      final result = await sl<GetContactInfoUseCase>()(NoParameters());
      result.fold(
        (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        (contactInfo) {
          if (mounted) {
            setState(() {
              _email = contactInfo.email;
              _phone = contactInfo.phone;
              _website = contactInfo.website;
              _isLoading = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.aboutApp,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App icon + name + version
            Center(
              child: Column(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB824), Color(0xFFFF5000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(5.w),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF892D).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 11.w,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10n.appName,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version =
                          snapshot.hasData ? snapshot.data!.version : '1.0.0';
                      return Text(
                        'v$version',
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            _SectionHeader(title: l10n.aboutApp),

            // Description
            _InfoCard(
              isDark: isDark,
              child: Text(
                l10n.aboutDescription,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),

            _SectionHeader(title: l10n.features),

            _FeatureTile(
              icon: Icons.manage_accounts_rounded,
              title: l10n.userAuthentication,
              subtitle: l10n.userAuthenticationDescription,
              isDark: isDark,
            ),
            _FeatureTile(
              icon: Icons.analytics_rounded,
              title: l10n.multiLanguageSupport,
              subtitle: l10n.multiLanguageSupportDescription,
              isDark: isDark,
            ),
            _FeatureTile(
              icon: Icons.tune_rounded,
              title: l10n.secureStorage,
              subtitle: l10n.secureStorageDescription,
              isDark: isDark,
            ),
            _FeatureTile(
              icon: Icons.map_rounded,
              title: l10n.googleSignIn,
              subtitle: l10n.googleSignInDescription,
              isDark: isDark,
            ),

            _SectionHeader(title: l10n.contactUs),

            if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFFFF892D),
                    strokeWidth: 2,
                  ),
                ),
              )
            else ...[
              if (_email != null && _email!.isNotEmpty)
                _ContactTile(
                  icon: Icons.email_outlined,
                  label: l10n.email,
                  value: _email!,
                  isDark: isDark,
                ),
              if (_phone != null && _phone!.isNotEmpty)
                _ContactTile(
                  icon: Icons.phone_outlined,
                  label: l10n.phone,
                  value: _phone!,
                  isDark: isDark,
                ),
              if (_website != null && _website!.isNotEmpty)
                _ContactTile(
                  icon: Icons.language_outlined,
                  label: l10n.website,
                  value: _website!,
                  isDark: isDark,
                ),
            ],

            SizedBox(height: 3.h),

            Center(
              child: Text(
                l10n.copyright,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(1.w, 1.h, 1.w, 1.5.h),
      child: Row(
        children: [
          Container(
            width: 1.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFF892D),
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.grey[800],
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _InfoCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceBright : Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        border:
            isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
      ),
      child: child,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceBright : Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        border:
            isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF892D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Icon(icon, color: const Color(0xFFFF892D), size: 20.sp),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.4,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceBright : Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        border:
            isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 0.8.h,
        ),
        leading: Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFF892D).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Icon(icon, color: const Color(0xFFFF892D), size: 20.sp),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
