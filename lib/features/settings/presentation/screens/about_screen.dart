import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:delivery_manager/core/theme/theme.dart';
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
      final getContactInfoUseCase = sl<GetContactInfoUseCase>();
      final result = await getContactInfoUseCase(NoParameters());

      result.fold(
        (failure) {
          // On error, use defaults or show error
          setState(() {
            _email = 'support@deliveryoperator.com';
            _phone = '+1 (555) 123-4567';
            _website = 'www.deliveryoperator.com';
            _isLoading = false;
          });
        },
        (contactInfo) {
          setState(() {
            _email = contactInfo.email;
            _phone = contactInfo.phone;
            _website = contactInfo.website;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      // Fallback to defaults on exception
      setState(() {
        _email = 'support@deliveryoperator.com';
        _phone = '+1 (555) 123-4567';
        _website = 'www.deliveryoperator.com';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.aboutApp)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // App Name
              Text(
                AppLocalizations.of(context)!.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              // App Version
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? snapshot.data!.version
                      : '1.0.0'; // Fallback to default if loading

                  return Text(
                    'Version $version',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // App Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.aboutDescription,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.contactUs,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        if (_email != null)
                          _buildContactItem(
                            context,
                            Icons.email,
                            AppLocalizations.of(context)!.email,
                            _email!,
                          ),
                        if (_phone != null)
                          _buildContactItem(
                            context,
                            Icons.phone,
                            AppLocalizations.of(context)!.phone,
                            _phone!,
                          ),
                        if (_website != null)
                          _buildContactItem(
                            context,
                            Icons.web,
                            AppLocalizations.of(context)!.website,
                            _website!,
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Copyright
              Text(
                AppLocalizations.of(context)!.copyright,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode
        ? Theme.of(context).colorScheme.inversePrimary
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
