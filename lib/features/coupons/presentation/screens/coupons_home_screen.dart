import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class CouponsHomeScreen extends StatelessWidget {
  const CouponsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.coupons)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: MaterialTheme.getGradientBackground(context),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: MaterialTheme.getSpacing('spacingGrid').w,
              runSpacing: MaterialTheme.getSpacing('spacingGrid').w * 3,
              children: [
                _buildIconContainer(
                  context,
                  title: localizations.restaurantCoupons,
                  iconPath: 'assets/images/pizza_boxes.ico',
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.restaurantCoupons,
                  ),
                ),
                _buildIconContainer(
                  context,
                  title: localizations.deliveryCoupons,
                  iconPath: 'assets/images/delivery_scooter.ico',
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.deliveryCoupons,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                SizedBox(
                  height:
                      MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
                  child: Center(child: _buildIcon(context, iconPath)),
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

  Widget _buildIcon(BuildContext context, String iconPath) {
    return Image.asset(
      iconPath,
      width: MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
      height: MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.error_outline,
          size: MaterialTheme.getSpacing('containerWidthMedium').w * 1.05,
          color: Theme.of(context).colorScheme.onSurface,
        );
      },
    );
  }
}
