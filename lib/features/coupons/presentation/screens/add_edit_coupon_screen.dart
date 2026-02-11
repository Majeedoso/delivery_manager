import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:delivery_manager/core/routes/app_routes.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/domain/entities/delivery_zone.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// Screen for creating or editing a coupon.
class AddEditCouponScreen extends StatefulWidget {
  final Coupon? coupon;
  final String discountTarget;

  const AddEditCouponScreen({
    super.key,
    this.coupon,
    this.discountTarget = 'subtotal',
  });

  bool get isEditing => coupon != null;

  @override
  State<AddEditCouponScreen> createState() => _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends State<AddEditCouponScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _valueController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxUsesTotalController;
  late final TextEditingController _maxUsesPerCustomerController;
  late final TextEditingController _minOrderValueController;
  late final TextEditingController _maxDiscountAmountController;

  String _selectedType = 'percentage';
  String _selectedStatus = 'draft';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  late String _discountTarget;

  int? _selectedRestaurantId;

  // Selected delivery zone IDs
  Set<int> _selectedDeliveryZoneIds = {};

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.coupon?.code ?? '');
    _valueController = TextEditingController(
      text: widget.coupon?.value.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.coupon?.description ?? '',
    );
    _maxUsesTotalController = TextEditingController(
      text: widget.coupon?.maxUsesTotal?.toString() ?? '',
    );
    _maxUsesPerCustomerController = TextEditingController(
      text: widget.coupon?.maxUsesPerCustomer?.toString() ?? '',
    );
    _minOrderValueController = TextEditingController(
      text: widget.coupon?.minOrderValue?.toString() ?? '',
    );
    _maxDiscountAmountController = TextEditingController(
      text: widget.coupon?.maxDiscountAmount?.toString() ?? '',
    );

    if (widget.coupon != null) {
      _selectedType = widget.coupon!.type;
      _selectedStatus = widget.coupon!.status;
      _startDate = widget.coupon!.startDate;
      _endDate = widget.coupon!.endDate;
      _discountTarget = widget.coupon!.discountTarget;
      // Load selected zone IDs from existing coupon
      _selectedDeliveryZoneIds = widget.coupon!.deliveryZoneIds.toSet();
      _selectedRestaurantId = widget.coupon!.restaurantId;
    } else {
      _discountTarget = widget.discountTarget;
    }

    // Add listeners to track changes
    _codeController.addListener(_onFieldChanged);
    _valueController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _maxUsesTotalController.addListener(_onFieldChanged);
    _maxUsesPerCustomerController.addListener(_onFieldChanged);
    _minOrderValueController.addListener(_onFieldChanged);
    _maxDiscountAmountController.addListener(_onFieldChanged);

    // Load coupon zones and restaurants
    context.read<CouponsBloc>().add(const LoadDeliveryZonesEvent());
    context.read<CouponsBloc>().add(const LoadRestaurantsEvent());
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    _maxUsesTotalController.dispose();
    _maxUsesPerCustomerController.dispose();
    _minOrderValueController.dispose();
    _maxDiscountAmountController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final localizations = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.discardChanges),
        content: Text(localizations.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.discard),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF781F),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
        _hasChanges = true;
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final code = _codeController.text.trim().toUpperCase();
    final value = int.parse(_valueController.text.trim());
    final description = _descriptionController.text.trim();
    final maxUsesTotal = _maxUsesTotalController.text.isNotEmpty
        ? int.parse(_maxUsesTotalController.text.trim())
        : null;
    final maxUsesPerCustomer = _maxUsesPerCustomerController.text.isNotEmpty
        ? int.parse(_maxUsesPerCustomerController.text.trim())
        : null;
    final minOrderValue = _minOrderValueController.text.isNotEmpty
        ? int.parse(_minOrderValueController.text.trim())
        : null;
    final maxDiscountAmount = _maxDiscountAmountController.text.isNotEmpty
        ? int.parse(_maxDiscountAmountController.text.trim())
        : null;

    // Get zone IDs list (empty list if none selected)
    final deliveryZoneIds = _selectedDeliveryZoneIds.isNotEmpty
        ? _selectedDeliveryZoneIds.toList()
        : <int>[];

    if (widget.isEditing) {
      context.read<CouponsBloc>().add(
        UpdateCouponEvent(
          id: widget.coupon!.id,
          code: code,
          type: _selectedType,
          value: value,
          status: _selectedStatus,
          startDate: _startDate,
          endDate: _endDate,
          restaurantId: _selectedRestaurantId,
          discountTarget: _discountTarget,
          maxUsesTotal: maxUsesTotal,
          maxUsesPerCustomer: maxUsesPerCustomer,
          minOrderValue: minOrderValue,
          maxDiscountAmount: maxDiscountAmount,
          description: description.isNotEmpty ? description : null,
          deliveryZoneIds: deliveryZoneIds,
        ),
      );
    } else {
      context.read<CouponsBloc>().add(
        CreateCouponEvent(
          code: code,
          type: _selectedType,
          value: value,
          status: _selectedStatus,
          startDate: _startDate,
          endDate: _endDate,
          restaurantId: _selectedRestaurantId,
          discountTarget: _discountTarget,
          maxUsesTotal: maxUsesTotal,
          maxUsesPerCustomer: maxUsesPerCustomer,
          minOrderValue: minOrderValue,
          maxDiscountAmount: maxDiscountAmount,
          description: description.isNotEmpty ? description : null,
          deliveryZoneIds: deliveryZoneIds,
        ),
      );
    }
  }

  void _toggleZone(int zoneId) {
    setState(() {
      if (_selectedDeliveryZoneIds.contains(zoneId)) {
        _selectedDeliveryZoneIds.remove(zoneId);
      } else {
        _selectedDeliveryZoneIds.add(zoneId);
      }
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: BlocListener<CouponsBloc, CouponsState>(
        listener: (context, state) {
          if (state.operationStatus == CouponOperationStatus.success) {
            Navigator.pop(context, true);
          } else if (state.operationStatus == CouponOperationStatus.failure &&
              state.operationMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.operationMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(widget.isEditing ? localizations.editCoupon : localizations.newCoupon),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              BlocBuilder<CouponsBloc, CouponsState>(
                builder: (context, state) {
                  final isLoading =
                      state.operationStatus == CouponOperationStatus.loading;
                  return TextButton(
                    onPressed: isLoading ? null : _onSave,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF781F),
                            ),
                          )
                        : Text(
                            widget.isEditing ? localizations.update : localizations.create,
                            style: TextStyle(
                              color: const Color(0xFFFF781F),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code field
                  _buildSectionTitle(localizations.couponCode),
                  TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDecoration(
                      hint: localizations.couponCodeHint,
                      prefixIcon: Icons.local_offer,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(50),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.pleaseEnterCouponCode;
                      }
                      if (value.trim().length < 3) {
                        return localizations.codeMinLength;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),

                  // Discount type and value
                  _buildSectionTitle(localizations.discount),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: _inputDecoration(
                            hint: localizations.type,
                            prefixIcon: Icons.discount,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'percentage',
                              child: Text(localizations.percentage),
                            ),
                            DropdownMenuItem(
                              value: 'fixed_amount',
                              child: Text(localizations.fixedAmount),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                                _hasChanges = true;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: localizations.value,
                            suffix: _selectedType == 'percentage' ? '%' : localizations.dzd,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return localizations.required;
                            }
                            final intValue = int.tryParse(value.trim());
                            if (intValue == null || intValue < 1) {
                              return localizations.min1;
                            }
                            if (_selectedType == 'percentage' &&
                                intValue > 100) {
                              return localizations.max100Percent;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Discount target (read-only)
                  _buildSectionTitle(localizations.discountAppliesTo),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _discountTarget == 'delivery_fee'
                              ? Icons.local_shipping
                              : Icons.receipt_long,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            _discountTarget == 'delivery_fee'
                                ? localizations.deliveryFee
                                : localizations.orderSubtotal,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Status
                  _buildSectionTitle(localizations.status),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: _inputDecoration(
                      hint: localizations.status,
                      prefixIcon: Icons.flag,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'draft',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: Colors.orange,
                              size: 18.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(localizations.draft),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'active',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(localizations.active),
                          ],
                        ),
                      ),
                      if (widget.isEditing)
                        DropdownMenuItem(
                          value: 'disabled',
                          child: Row(
                            children: [
                              Icon(
                                Icons.pause_circle,
                                color: Colors.grey,
                                size: 18.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(localizations.disabled),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                          _hasChanges = true;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 3.h),

                  // Validity dates
                  _buildSectionTitle(localizations.validityPeriod),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: localizations.startDate,
                          date: _startDate,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildDateField(
                          label: localizations.endDate,
                          date: _endDate,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Restaurant targeting
                  _buildSectionTitle(localizations.restaurantOptional),
                  _buildRestaurantSelector(),
                  SizedBox(height: 3.h),

                  // Coupon Zones
                  _buildSectionTitle(
                    localizations.couponZonesOptional,
                    action: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFFFF781F),
                      ),
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.deliveryZones),
                      tooltip: localizations.manageZones,
                    ),
                  ),
                  _buildZonesSection(),
                  SizedBox(height: 3.h),

                  // Usage limits
                  _buildSectionTitle(localizations.usageLimitsOptional),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _maxUsesTotalController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: localizations.totalUses,
                            prefixIcon: Icons.all_inclusive,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final intValue = int.tryParse(value);
                              if (intValue == null || intValue < 1) {
                                return localizations.min1;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: TextFormField(
                          controller: _maxUsesPerCustomerController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: localizations.perCustomer,
                            prefixIcon: Icons.person,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final intValue = int.tryParse(value);
                              if (intValue == null || intValue < 1) {
                                return localizations.min1;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Order constraints
                  _buildSectionTitle(localizations.orderConstraintsOptional),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minOrderValueController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: localizations.minOrderDzd,
                            prefixIcon: Icons.shopping_cart,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: TextFormField(
                          controller: _maxDiscountAmountController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            hint: localizations.maxDiscountDzd,
                            prefixIcon: Icons.money,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Description
                  _buildSectionTitle(localizations.descriptionOptional),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: _inputDecoration(
                      hint: localizations.internalNoteHint,
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZonesSection() {
    return BlocBuilder<CouponsBloc, CouponsState>(
      builder: (context, state) {
        final localizations = AppLocalizations.of(context)!;
        if (state.isLoadingZones) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFF781F),
                ),
              ),
            ),
          );
        }

        if (state.zonesErrorMessage != null) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade400),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    state.zonesErrorMessage!,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<CouponsBloc>().add(
                      const LoadDeliveryZonesEvent(),
                    );
                  },
                  child: Text(localizations.retry),
                ),
              ],
            ),
          );
        }

        if (state.deliveryZones.isEmpty) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade500),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        localizations.noCouponZonesAvailable,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.deliveryZones);
                  },
                  icon: const Icon(Icons.add_location_alt),
                  label: Text(localizations.manageZones),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF781F),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey.shade500,
                      size: 18.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _selectedDeliveryZoneIds.isEmpty
                          ? localizations.selectZonesInfo
                          : '${_selectedDeliveryZoneIds.length} ${_selectedDeliveryZoneIds.length != 1 ? localizations.zones : localizations.zone} selected',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...state.deliveryZones.map((zone) => _buildZoneItem(zone)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantSelector() {
    return BlocBuilder<CouponsBloc, CouponsState>(
      builder: (context, state) {
        final localizations = AppLocalizations.of(context)!;
        if (state.isLoadingRestaurants && state.restaurants.isEmpty) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFF781F),
                ),
              ),
            ),
          );
        }

        if (state.restaurantsErrorMessage != null &&
            state.restaurants.isEmpty) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade400),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    state.restaurantsErrorMessage!,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<CouponsBloc>().add(
                      const LoadRestaurantsEvent(refresh: true),
                    );
                  },
                  child: Text(localizations.retry),
                ),
              ],
            ),
          );
        }

        if (state.restaurants.isEmpty) {
          return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade500),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    localizations.noRestaurantsAvailable,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final restaurantItems = state.restaurants
            .map((restaurant) {
              final idRaw = restaurant['id'];
              final id = idRaw is int
                  ? idRaw
                  : int.tryParse(idRaw?.toString() ?? '');
              if (id == null) return null;
              final name = restaurant['name']?.toString() ?? 'Unknown';
              return DropdownMenuItem<int?>(
                value: id,
                child: Text(name),
              );
            })
            .whereType<DropdownMenuItem<int?>>()
            .toList();

        final selectedId = _selectedRestaurantId;
        final hasSelected = selectedId != null &&
            restaurantItems.any((item) => item.value == selectedId);
        if (selectedId != null && !hasSelected) {
          restaurantItems.insert(
            0,
            DropdownMenuItem<int?>(
              value: selectedId,
              child: Text(widget.coupon?.restaurantName ?? localizations.selectedRestaurant),
            ),
          );
        }

        return DropdownButtonFormField<int?>(
          value: _selectedRestaurantId,
          decoration: _inputDecoration(
            hint: localizations.allRestaurantsGlobal,
            prefixIcon: Icons.restaurant,
          ),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(localizations.allRestaurantsGlobal),
            ),
            ...restaurantItems,
          ],
          onChanged: (value) {
            setState(() {
              _selectedRestaurantId = value;
              _hasChanges = true;
            });
          },
        );
      },
    );
  }

  Widget _buildZoneItem(DeliveryZone zone) {
    final localizations = AppLocalizations.of(context)!;
    final isSelected = _selectedDeliveryZoneIds.contains(zone.id);
    return InkWell(
      onTap: () => _toggleZone(zone.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleZone(zone.id),
              activeColor: const Color(0xFFFF781F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          zone.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFFF781F)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (zone.description != null && zone.description!.isNotEmpty)
                    Text(
                      zone.description!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (zone.radiusKm != null)
                    Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Text(
                        '${zone.radiusKm!.toStringAsFixed(1)} ${localizations.kmRadius}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFFFF781F),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? action}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    IconData? prefixIcon,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey.shade500)
          : null,
      suffixText: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF781F), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey.shade500,
              size: 18.sp,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    dateFormat.format(date),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
