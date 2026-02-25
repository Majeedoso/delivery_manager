import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class StatisticsRatingsScreen extends StatelessWidget {
  static const String route = '/statistics/ratings';

  const StatisticsRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.statisticsRatings)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(2.5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 4.h),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: MaterialTheme.getSpacing('spacingGrid').w,
                runSpacing: MaterialTheme.getSpacing('spacingGrid').w * 3,
                children: [
                  _buildIconContainer(
                    context,
                    title: l.overview,
                    icon: Icons.bar_chart,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.statisticsRatingsOverview),
                  ),
                  _buildIconContainer(
                    context,
                    title: l.restaurantsTab,
                    icon: Icons.store,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.statisticsRatingsRestaurants),
                  ),
                  _buildIconContainer(
                    context,
                    title: l.driversTab,
                    icon: Icons.delivery_dining,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.statisticsRatingsDrivers),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(
    BuildContext context, {
    required String title,
    required IconData icon,
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
                SizedBox(
                  height: MaterialTheme.getSpacing('containerWidthMedium').w *
                      1.05,
                  child: Center(
                    child: Icon(
                      icon,
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
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurface,
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
}
