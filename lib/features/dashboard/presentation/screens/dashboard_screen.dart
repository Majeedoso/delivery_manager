import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_event.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadSettingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboard)),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.settingsStatus == DashboardSettingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.settingsStatus == DashboardSettingsStatus.error) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      state.errorMessage ?? l10n.failedToLoadSettings,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<DashboardBloc>()
                          .add(const LoadSettingsEvent(refresh: true)),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          // Group settings by category to get category list + counts
          final grouped = <String, List<AppDashboard>>{};
          for (final setting in state.settings) {
            grouped.putIfAbsent(setting.category, () => []).add(setting);
          }
          final categories = grouped.keys.toList()..sort();

          if (categories.isEmpty &&
              state.settingsStatus == DashboardSettingsStatus.loaded) {
            return Center(child: Text(l10n.noSettingsFound));
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: MaterialTheme.getGradientBackground(context),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: MaterialTheme.getPaddingLarge(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: MaterialTheme.getSpacing('spacingGrid').w,
                  runSpacing: MaterialTheme.getSpacing('spacingGrid').w * 3,
                  children: categories
                      .map((c) => _buildCategoryTile(context, c))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String category) {
    return SizedBox(
      width: MaterialTheme.getSpacing('containerWidthLarge').w,
      height: MaterialTheme.getSpacing('containerWidthLarge').w,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: MaterialTheme.getBorderRadiusButton(),
        ),
        child: InkWell(
          borderRadius: MaterialTheme.getBorderRadiusButton(),
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.dashboardCategory,
            arguments: {'category': category},
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height:
                      MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(category),
                      size:
                          MaterialTheme.getSpacing('containerWidthMedium').w *
                          1.05,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 0.1.h),
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
                          _formatLabel(category),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'delivery':
        return Icons.local_shipping;
      case 'financials':
        return Icons.account_balance;
      case 'customers_orders':
        return Icons.people;
      case 'loyalty_promotions':
        return Icons.card_giftcard;
      case 'api_integrations':
        return Icons.api;
      case 'legal_contact':
        return Icons.gavel;
      default:
        return Icons.settings;
    }
  }

  String _formatLabel(String raw) {
    const labels = {
      'customers_orders': 'Customers & Orders',
      'loyalty_promotions': 'Loyalty & Promotions',
      'api_integrations': 'API & Integrations',
      'legal_contact': 'Legal & Contact',
    };
    if (labels.containsKey(raw.toLowerCase())) return labels[raw.toLowerCase()]!;
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
