import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/utils/error_message_mapper.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/features/coupons/presentation/screens/add_edit_coupon_screen.dart';
import 'package:intl/intl.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// Screen to display and manage manager coupons.
class CouponsListScreen extends StatefulWidget {
  final String title;
  final String discountTarget;

  const CouponsListScreen({
    super.key,
    required this.title,
    required this.discountTarget,
  });

  @override
  State<CouponsListScreen> createState() => _CouponsListScreenState();
}

class _CouponsListScreenState extends State<CouponsListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The route's bloc: the page made a second one, which the status filter
    // and the next pages never reached
    context.read<CouponsBloc>().add(
      LoadCouponsEvent(refresh: true, discountTarget: widget.discountTarget),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final bloc = context.read<CouponsBloc>();
      final state = bloc.state;
      if (!state.isLoading && !state.isLoadingMore && state.hasMore) {
        bloc.add(
          LoadCouponsEvent(
            status: _selectedStatus,
            page: state.currentPage + 1,
            discountTarget: widget.discountTarget,
          ),
        );
      }
    }
  }

  void _onStatusFilterChanged(String? status) {
    setState(() => _selectedStatus = status);
    context.read<CouponsBloc>().add(
      LoadCouponsEvent(
        status: status,
        refresh: true,
        discountTarget: widget.discountTarget,
      ),
    );
  }

  /// A coupon's status in the manager's language (it was the server's word,
  /// in capitals: ACTIVE, DRAFT, DISABLED).
  String _statusLabel(AppLocalizations localizations, String status) =>
      switch (status) {
        'active' => localizations.active,
        'draft' => localizations.draft,
        'disabled' => localizations.disabled,
        _ => status,
      };

  /// Who issued a coupon, in the manager's language ("manager" was shown).
  String _issuerLabel(AppLocalizations localizations, String issuer) =>
      switch (issuer) {
        'manager' => localizations.manager,
        'restaurant' => localizations.restaurant,
        _ => issuer,
      };

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'disabled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'draft':
        return Icons.edit_note;
      case 'disabled':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // The light grey stayed under dark mode's black bar and dark cards
      backgroundColor: isDark ? null : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String?>(
            icon: Icon(
              Icons.filter_list,
              color: isDark
                  ? Colors.white
                  : _selectedStatus != null
                  ? const Color(0xFFFF781F)
                  : Colors.grey,
            ),
            onSelected: _onStatusFilterChanged,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(localizations.all)),
              PopupMenuItem(value: 'active', child: Text(localizations.active)),
              PopupMenuItem(value: 'draft', child: Text(localizations.draft)),
              PopupMenuItem(
                value: 'disabled',
                child: Text(localizations.disabled),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CouponsBloc>(),
                    child: AddEditCouponScreen(
                      discountTarget: widget.discountTarget,
                    ),
                  ),
                ),
              );
              if (result == true && context.mounted) {
                context.read<CouponsBloc>().add(
                  LoadCouponsEvent(
                    refresh: true,
                    discountTarget: widget.discountTarget,
                  ),
                );
              }
            },
            backgroundColor: const Color(0xFFFF781F),
            icon: const Icon(Icons.add),
            label: Text(
              widget.discountTarget == 'delivery_fee'
                  ? localizations.newDeliveryCoupon
                  : localizations.newCoupon,
            ),
          );
        },
      ),
      // No message here: the saved coupon shows in the list, and the form
      // says a failure (both said it, the success in English)
      body: BlocBuilder<CouponsBloc, CouponsState>(
        builder: (context, state) {
          if (state.isLoading && state.coupons.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFFFF8A32),
              ),
            );
          }

          if (state.errorMessage != null && state.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    ErrorMessageMapper.getUserFriendlyMessage(
                      state.errorMessage!,
                      localizations,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => context.read<CouponsBloc>().add(
                      LoadCouponsEvent(
                        status: _selectedStatus,
                        refresh: true,
                        discountTarget: widget.discountTarget,
                      ),
                    ),
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            );
          }

          if (state.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.discountTarget == 'delivery_fee'
                        ? localizations.noDeliveryCouponsYet
                        : localizations.noCouponsYet,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    widget.discountTarget == 'delivery_fee'
                        ? localizations.createFirstDeliveryCoupon
                        : localizations.createFirstCoupon,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CouponsBloc>().add(
                LoadCouponsEvent(
                  status: _selectedStatus,
                  refresh: true,
                  discountTarget: widget.discountTarget,
                ),
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              itemCount: state.coupons.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.coupons.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFFFF8A32),
                      ),
                    ),
                  );
                }
                return _buildCouponCard(context, state.coupons[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, Coupon coupon) {
    final localizations = AppLocalizations.of(context)!;
    // In the manager's language ("12 sept. 2026", not "Sep 12, 2026")
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );
    final statusColor = _getStatusColor(coupon.status);

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CouponsBloc>(),
                child: AddEditCouponScreen(
                  coupon: coupon,
                  discountTarget: coupon.discountTarget,
                ),
              ),
            ),
          );
          if (result == true && context.mounted) {
            context.read<CouponsBloc>().add(
              LoadCouponsEvent(
                refresh: true,
                discountTarget: widget.discountTarget,
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with code and status
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF781F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: const Color(0xFFFF781F),
                          size: 16.sp,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          coupon.code,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF781F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(coupon.status),
                          color: statusColor,
                          size: 14.sp,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _statusLabel(
                            localizations,
                            coupon.status,
                          ).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Targeting info
              Row(
                children: [
                  Icon(Icons.store, size: 14.sp, color: Colors.grey.shade500),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      coupon.restaurantName != null
                          ? '${localizations.restaurant} ${coupon.restaurantName}'
                          : localizations.globalAllRestaurants,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (coupon.issuerType != null) ...[
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        '${localizations.issuer} ${_issuerLabel(localizations, coupon.issuerType!)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 2.h),

              // Discount display
              Row(
                children: [
                  Text(
                    coupon.type == 'percentage'
                        ? '${coupon.value}%'
                        : '${coupon.value} ${localizations.dzd}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      // Black was lost on dark mode's dark card
                      color:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    coupon.type == 'percentage'
                        ? localizations.off
                        : localizations.discount,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              if (coupon.description != null &&
                  coupon.description!.isNotEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  coupon.description!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 2.h),
              const Divider(height: 1),
              SizedBox(height: 2.h),

              // Details row
              Row(
                children: [
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    label: localizations.valid,
                    value:
                        '${dateFormat.format(coupon.startDate)} - ${dateFormat.format(coupon.endDate)}',
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  _buildDetailItem(
                    icon: Icons.people,
                    label: localizations.uses,
                    value: coupon.maxUsesTotal != null
                        ? '${coupon.usagesCount}/${coupon.maxUsesTotal}'
                        : localizations.usesUnlimited(coupon.usagesCount),
                  ),
                  SizedBox(width: 4.w),
                  if (coupon.minOrderValue != null)
                    _buildDetailItem(
                      icon: Icons.receipt,
                      label: localizations.minOrder,
                      value: '${coupon.minOrderValue} ${localizations.dzd}',
                    ),
                ],
              ),

              // Expiry warning
              if (coupon.isExpired) ...[
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 14.sp),
                      SizedBox(width: 1.w),
                      Text(
                        localizations.expired,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey.shade500),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
