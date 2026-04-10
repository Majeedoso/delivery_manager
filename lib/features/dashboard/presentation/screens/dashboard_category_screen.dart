import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/dashboard/domain/entities/app_dashboard.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_event.dart';
import 'package:delivery_manager/features/dashboard/presentation/controller/dashboard_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

class DashboardCategoryScreen extends StatefulWidget {
  final String category;

  const DashboardCategoryScreen({super.key, required this.category});

  @override
  State<DashboardCategoryScreen> createState() =>
      _DashboardCategoryScreenState();
}

class _DashboardCategoryScreenState extends State<DashboardCategoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(
      LoadSettingsEvent(category: widget.category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_formatLabel(widget.category))),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.updateStatus == DashboardUpdateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.settingUpdatedSuccessfully),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state.updateStatus == DashboardUpdateStatus.error &&
              state.updateErrorMessage != null) {
            ErrorSnackBar.show(context, state.updateErrorMessage!);
          }
        },
        builder: (context, state) {
          if (state.settingsStatus == DashboardSettingsStatus.loading &&
              state.settings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.settingsStatus == DashboardSettingsStatus.error &&
              state.settings.isEmpty) {
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
                      onPressed: () => context.read<DashboardBloc>().add(
                        LoadSettingsEvent(
                          category: widget.category,
                          refresh: true,
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.settings.isEmpty &&
              state.settingsStatus == DashboardSettingsStatus.loaded) {
            return Center(child: Text(l10n.noSettingsInThisCategory));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                LoadSettingsEvent(category: widget.category, refresh: true),
              );
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
              itemCount: state.settings.length,
              itemBuilder: (context, index) {
                return _buildSettingCard(context, state.settings[index], state);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    AppDashboard setting,
    DashboardState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isUpdatingThis =
        state.updatingSettingId == setting.id &&
        state.updateStatus == DashboardUpdateStatus.loading;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 0.4.h, horizontal: 1.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isUpdatingThis ? null : () => _showInfoDialog(context, setting),
        onLongPress: isUpdatingThis
            ? null
            : () => _showEditBottomSheet(context, setting),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatLabel(setting.key),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Wrap(
                      spacing: 1.w,
                      runSpacing: 0.3.h,
                      children: [
                        _buildChip(
                          context,
                          setting.value.isEmpty
                              ? l10n.emptyInParentheses
                              : setting.value,
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        _buildChip(
                          context,
                          setting.type,
                          Theme.of(context).colorScheme.secondaryContainer,
                          Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ],
                    ),
                    SizedBox(height: 0.3.h),
                  ],
                ),
              ),
              if (isUpdatingThis) ...[
                SizedBox(width: 2.w),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFFFF8A32),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Tap: info dialog ───────────────────────────────────────────────────────

  static const Map<String, _SettingInfo> _settingExplanations = {
    // ── api ──────────────────────────────────────────────────────────────────
    'mapbox_access_token': _SettingInfo(
      role: 'Primary routing engine',
      explanation:
          'This token authenticates the app with the Mapbox API. '
          'Mapbox is the first service the system tries when it needs to calculate '
          'the real road distance and estimated travel time between a restaurant '
          'and a customer\'s delivery address. Without a valid token, distance '
          'calculations fall back to OpenRouteService or a straight-line estimate.',
    ),
    'openrouteservice_api_key': _SettingInfo(
      role: 'Fallback routing engine',
      explanation:
          'This key authenticates with OpenRouteService, which is used as a '
          'backup when the Mapbox API is unavailable or returns an error. '
          'Having a working fallback key ensures delivery fee and duration '
          'calculations remain accurate even if the primary routing provider '
          'has an outage.',
    ),

    // ── bank ─────────────────────────────────────────────────────────────────
    'system_manager_order_percentage': _SettingInfo(
      role: 'Platform commission on order subtotal',
      explanation:
          'The percentage of every order\'s food subtotal that the platform '
          'retains as its commission. For example, a value of 10 means the '
          'platform earns 10 DZD for every 100 DZD worth of food ordered. '
          'This is recorded in the cash reconciliation system and deducted '
          'when calculating what the driver owes the restaurant.',
    ),
    'system_manager_delivery_fee_percentage': _SettingInfo(
      role: 'Platform share of delivery fee',
      explanation:
          'The percentage of the delivery fee that goes to the platform. '
          'The remainder goes to the driver. For example, if set to 30, the '
          'platform keeps 30% of each delivery fee and the driver receives 70%. '
          'This split is used by the Cash Reconciliation Service every time an '
          'order is marked as delivered.',
    ),

    // ── contact ──────────────────────────────────────────────────────────────
    'contact_email': _SettingInfo(
      role: 'Support email shown in all apps',
      explanation:
          'This email address is returned by the public /app/contact-info '
          'endpoint and displayed in the Contact / About screen of every client '
          'app (customer, driver, restaurant, operator). Update it whenever your '
          'support email changes so users always reach the right inbox.',
    ),
    'contact_phone': _SettingInfo(
      role: 'Support phone number shown in all apps',
      explanation:
          'This phone number is displayed on the Contact screen of every client '
          'app. It is fetched live from the server, so changing it here updates '
          'all apps immediately without requiring a new app release.',
    ),
    'contact_website': _SettingInfo(
      role: 'Official website shown in all apps',
      explanation:
          'The URL of your platform\'s website, shown in the About / Contact '
          'section of all client apps. Typically opened in the device browser '
          'when the user taps it.',
    ),

    // ── delivery ─────────────────────────────────────────────────────────────
    'minimum_delivery_fee': _SettingInfo(
      role: 'Floor cap on the delivery fee',
      explanation:
          'The minimum amount a customer will ever be charged for delivery, '
          'regardless of how close the restaurant is. For example, a value of '
          '50 means even a 300-meter order still costs 50 DZD for delivery. '
          'Set to 0 to disable the minimum — the formula result is used as-is.',
    ),
    'maximum_delivery_fee': _SettingInfo(
      role: 'Ceiling cap on the delivery fee',
      explanation:
          'The maximum amount a customer can be charged for delivery, regardless '
          'of how far the restaurant is. For example, a value of 500 means a '
          '20 km order is never more than 500 DZD. '
          'Set to 0 to disable the cap — the formula result is used as-is.',
    ),
    'max_driver_concurrent_orders': _SettingInfo(
      role: 'Maximum simultaneous orders per driver',
      explanation:
          'The highest number of active orders a single driver can hold at the '
          'same time. Once a driver reaches this limit, new orders will not be '
          'dispatched to them until they complete or hand off an existing one. '
          'Increase this for high-demand periods; lower it to ensure drivers '
          'stay focused and delivery times remain short.',
    ),
    'fixed_delivery_fee': _SettingInfo(
      role: 'Base flat delivery charge',
      explanation:
          'A flat fee added to every order regardless of distance. This is the '
          'starting point of the delivery fee formula: '
          'total = fixed_fee + (price_per_meter × distance_in_meters). '
          'Raising this value increases the minimum any customer pays for delivery.',
    ),
    'price_per_meter': _SettingInfo(
      role: 'Distance-based delivery cost rate',
      explanation:
          'The additional cost charged per meter of road distance between the '
          'restaurant and the delivery address. For example, 0.02 DZD/m means '
          'a 5 km route adds 100 DZD on top of the fixed fee. '
          'This value is multiplied by the route distance returned by Mapbox '
          'or OpenRouteService.',
    ),
    'max_delivery_distance_km': _SettingInfo(
      role: 'Maximum allowed delivery radius',
      explanation:
          'Orders whose delivery address is farther than this many kilometres '
          'from the restaurant are rejected at order-creation time. '
          'This protects drivers from unreasonably long trips and keeps '
          'delivery times predictable. Adjust it to expand or restrict your '
          'service area.',
    ),
    'average_city_speed_kmh': _SettingInfo(
      role: 'City driving speed for duration estimates',
      explanation:
          'When both Mapbox and OpenRouteService are unavailable, the system '
          'falls back to a straight-line (Haversine) distance estimate and uses '
          'this speed to calculate how long the delivery will take through '
          'city streets. A typical value is 25–40 km/h to account for traffic '
          'and stops.',
    ),
    'average_highway_speed_kmh': _SettingInfo(
      role: 'Highway driving speed for duration estimates',
      explanation:
          'Used alongside the city speed in the Haversine fallback. Once the '
          'route distance exceeds the city/highway transition threshold, the '
          'system assumes the driver is on a faster road and uses this speed '
          'for the remaining distance. A typical value is 80–120 km/h.',
    ),
    'city_highway_transition_km': _SettingInfo(
      role: 'Distance threshold between city and highway driving',
      explanation:
          'In the Haversine duration fallback, routes shorter than this value '
          'are calculated entirely at city speed. Beyond this distance, the '
          'extra kilometres are calculated at highway speed. '
          'For example, a value of 5 means the first 5 km use city speed '
          'and everything beyond uses highway speed.',
    ),

    // ── earnings ─────────────────────────────────────────────────────────────
    'driver_earnings_percentage': _SettingInfo(
      role: 'Driver\'s share of the delivery fee',
      explanation:
          'The percentage of each delivery fee that is credited to the driver '
          'as their earnings. For example, 70 means the driver keeps 70% of '
          'the delivery fee; the platform takes the rest. '
          'This value is applied in the Order Controller when an order is '
          'completed and the settlement is calculated.',
    ),

    // ── general ──────────────────────────────────────────────────────────────
    'currency': _SettingInfo(
      role: 'Platform currency code',
      explanation:
          'The ISO 4217 currency code used for every monetary value displayed '
          'across the platform — order totals, delivery fees, earnings, and '
          'notifications. For example, "DZD" for Algerian Dinar. '
          'This value is appended to amounts throughout the backend and sent '
          'to all client apps.',
    ),
    'birthday_gift_enabled': _SettingInfo(
      role: 'Toggle birthday discount feature',
      explanation:
          'When set to true (or 1), customers who place an order on their '
          'birthday automatically receive a discount. When false (or 0), '
          'the feature is completely disabled and no birthday check is '
          'performed. Use this to turn the promotion on or off without '
          'touching any code.',
    ),
    'birthday_gift_cap': _SettingInfo(
      role: 'Maximum birthday discount amount',
      explanation:
          'The upper limit on how much discount a customer can receive as a '
          'birthday gift, expressed in the platform currency. For example, '
          'a cap of 500 means a customer whose order would normally earn a '
          '700 DZD birthday discount only gets 500 DZD off. '
          'This prevents the feature from being exploited on very large orders.',
    ),
    'customer_restaurant_radius_km': _SettingInfo(
      role: 'Nearby restaurant search radius',
      explanation:
          'When a customer opens the app, only restaurants whose location '
          'falls within this radius (in kilometres) of the customer\'s '
          'coordinates are shown. Increasing this value shows more options '
          'but may include restaurants that cannot realistically deliver '
          'within a reasonable time.',
    ),
    'customer_restaurant_prefilter_radius_km': _SettingInfo(
      role: 'Database pre-filter radius for restaurant queries',
      explanation:
          'Before applying the precise radius check, the system uses this '
          'larger value to quickly filter the database to a smaller candidate '
          'set. It should always be equal to or greater than the main search '
          'radius. Setting it too small will cause nearby restaurants to be '
          'excluded; setting it too large wastes database resources.',
    ),

    // ── legal ────────────────────────────────────────────────────────────────
    'privacy_policy_url': _SettingInfo(
      role: 'Privacy Policy link shown in all apps',
      explanation:
          'This URL is returned by the public /app/legal-urls endpoint and '
          'opened in the device browser when a user taps "Privacy Policy" in '
          'any client app. Update it here whenever you publish a new version '
          'of your privacy policy — no app update required.',
    ),
    'terms_of_service_url': _SettingInfo(
      role: 'Terms of Service link shown in all apps',
      explanation:
          'This URL is returned by the public /app/legal-urls endpoint and '
          'opened in the device browser when a user taps "Terms of Service" '
          'in any client app. Update it here whenever you revise your terms '
          'of service — no app update required.',
    ),

    // ── orders ───────────────────────────────────────────────────────────────
    'min_order_scheduling_minutes': _SettingInfo(
      role: 'Minimum advance notice for scheduled orders',
      explanation:
          'The minimum number of minutes in the future that a customer must '
          'set when scheduling an order for a specific time. For example, '
          'a value of 30 means customers cannot schedule an order for delivery '
          'within the next 30 minutes — they must pick a time at least '
          '30 minutes away. This gives restaurants and drivers enough lead time.',
    ),

    // ── trust ────────────────────────────────────────────────────────────────
    'number_of_orders_to_be_trusted': _SettingInfo(
      role: 'Orders needed to become a trusted customer',
      explanation:
          'New customers must pass through operator verification before their '
          'orders reach the restaurant. Once a customer has successfully '
          'completed this many delivered orders, their account is automatically '
          'promoted to "trusted" status and future orders skip the verification '
          'step entirely, going straight to the restaurant. '
          'Lowering this value fast-tracks trust; raising it adds more scrutiny.',
    ),

    // ── loyalty & promotions ─────────────────────────────────────────────────
    'loyalty_enabled': _SettingInfo(
      role: 'Enable or disable the loyalty points system',
      explanation:
          'When true, customers earn points on every delivered order and can '
          'redeem them for discount coupons. When false, no points are awarded '
          'and the redemption endpoint returns an error. Use this to pause the '
          'loyalty programme without deleting any existing point balances.',
    ),
    'loyalty_earn_rate': _SettingInfo(
      role: 'Points earned per DZD spent',
      explanation:
          'The number of loyalty points a customer receives for each Algerian '
          'Dinar of their order subtotal (excluding the delivery fee). '
          'For example, a value of 0.1 means a 1000 DZD order earns 100 points. '
          'Increasing this rate makes the programme more rewarding; '
          'decreasing it reduces the cost to the platform.',
    ),
    'loyalty_redeem_rate': _SettingInfo(
      role: 'DZD discount value per point redeemed',
      explanation:
          'How much one loyalty point is worth when a customer redeems it '
          'for a coupon. For example, a value of 0.5 means 200 points '
          'generates a 100 DZD discount coupon. This controls the real '
          'monetary cost of the loyalty programme — lower values protect '
          'margins; higher values attract more redemptions.',
    ),
    'loyalty_min_redeem_points': _SettingInfo(
      role: 'Minimum points required to redeem',
      explanation:
          'Customers cannot redeem fewer than this many points in a single '
          'transaction. Setting a floor (e.g. 100 points) prevents customers '
          'from generating tiny, administratively costly coupons and encourages '
          'them to accumulate a meaningful balance before redeeming.',
    ),
    'loyalty_tiers': _SettingInfo(
      role: 'Point thresholds for redemption tiers',
      explanation:
          'A JSON array listing the exact point amounts customers can redeem '
          'at one time (e.g. [100, 500, 1000, 2000]). When a customer opens '
          'the redemption screen, only these tier options are shown. '
          'Each tier must be ≥ loyalty_min_redeem_points. '
          'Edit as a valid JSON array: [value1, value2, ...].',
    ),
    'max_coupons_per_category': _SettingInfo(
      role: 'Max coupons of the same type per order',
      explanation:
          'The maximum number of coupons from the same category (e.g. two '
          '"percentage off" coupons) that can be applied to a single order. '
          'Setting this to 1 prevents customers from stacking multiple '
          'discount codes of the same kind. Increase it if you want to allow '
          'combining similar promotions.',
    ),
    'max_coupon_categories': _SettingInfo(
      role: 'Max different coupon types per order',
      explanation:
          'The maximum number of different coupon categories (e.g. one '
          'percentage coupon + one loyalty coupon) that can be active on a '
          'single order at the same time. This is the overall coupon stack '
          'limit. For example, a value of 2 means a customer can apply at '
          'most 2 different types of discounts to one order.',
    ),
  };

  void _showInfoDialog(BuildContext context, AppDashboard setting) {
    final l10n = AppLocalizations.of(context)!;
    final info = _settingExplanations[setting.key];
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_formatLabel(setting.key)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role badge
              if (info != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    info.role,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 1.2.h),
                // Detailed explanation
                Text(
                  info.explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 1.5.h),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                SizedBox(height: 1.2.h),
              ],
              _buildInfoRow(
                context,
                l10n.currentValue,
                setting.value.isEmpty ? l10n.emptyInParentheses : setting.value,
              ),
              SizedBox(height: 0.8.h),
              _buildInfoRow(context, l10n.type, setting.type),
              SizedBox(height: 0.8.h),
              _buildInfoRow(context, l10n.keyLabel, setting.key),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(value, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  // ── Long-tap: bottom sheet → edit dialog ──────────────────────────────────

  void _showEditBottomSheet(BuildContext context, AppDashboard setting) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<DashboardBloc>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 0.8.h),
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  _formatLabel(setting.key),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 0.5.h),
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.editValue),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showEditDialog(context, setting, bloc);
                },
              ),
              SizedBox(height: 1.h),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    AppDashboard setting,
    DashboardBloc bloc,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _SettingEditDialog(
        setting: setting,
        onConfirm: (value) =>
            bloc.add(UpdateSettingEvent(id: setting.id, value: value)),
      ),
    );
  }

  String _formatLabel(String raw) {
    const labels = {
      'customers_orders': 'Customers & Orders',
      'loyalty_promotions': 'Loyalty & Promotions',
      'api_integrations': 'API & Integrations',
      'legal_contact': 'Legal & Contact',
    };
    if (labels.containsKey(raw.toLowerCase()))
      return labels[raw.toLowerCase()]!;
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// ── Edit dialog (StatefulWidget owns the TextEditingController) ───────────────

class _SettingEditDialog extends StatefulWidget {
  final AppDashboard setting;
  final void Function(String value) onConfirm;

  const _SettingEditDialog({required this.setting, required this.onConfirm});

  @override
  State<_SettingEditDialog> createState() => _SettingEditDialogState();
}

class _SettingEditDialogState extends State<_SettingEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.setting.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_formatLabel(widget.setting.key)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.setting.description.isNotEmpty) ...[
            Text(
              widget.setting.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
          ],
          Row(
            children: [
              Text(
                '${AppLocalizations.of(context)!.type}: ',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                widget.setting.type,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.newValue,
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            keyboardType: _getKeyboardType(widget.setting.type),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final newValue = _controller.text.trim();
            if (newValue.isEmpty) return;
            Navigator.of(context).pop();
            widget.onConfirm(newValue);
          },
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
  }

  String _formatLabel(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  TextInputType _getKeyboardType(String type) {
    switch (type) {
      case 'integer':
      case 'int':
        return TextInputType.number;
      case 'decimal':
      case 'float':
      case 'number':
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }
}

// ── Data class for setting explanations ──────────────────────────────────────

class _SettingInfo {
  final String role;
  final String explanation;

  const _SettingInfo({required this.role, required this.explanation});
}
