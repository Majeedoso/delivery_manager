import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/features/coupons/domain/entities/delivery_zone.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_bloc.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_event.dart';
import 'package:delivery_manager/features/coupons/presentation/controller/coupons_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// Screen for managing coupon zones.
class DeliveryZonesScreen extends StatefulWidget {
  const DeliveryZonesScreen({super.key});

  @override
  State<DeliveryZonesScreen> createState() => _DeliveryZonesScreenState();
}

class _DeliveryZonesScreenState extends State<DeliveryZonesScreen> {
  @override
  void initState() {
    super.initState();
    // Load zones when screen opens
    context.read<CouponsBloc>().add(const LoadDeliveryZonesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.couponZones),
        backgroundColor: const Color(0xFFFF781F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showZoneDialog(),
            tooltip: localizations.addZone,
          ),
        ],
      ),
      body: BlocConsumer<CouponsBloc, CouponsState>(
        listenWhen: (previous, current) =>
            previous.zoneOperationStatus != current.zoneOperationStatus,
        listener: (context, state) {
          final localizations = AppLocalizations.of(context)!;
          if (state.zoneOperationStatus == ZoneOperationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.zoneOperationMessage ?? localizations.success),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.zoneOperationStatus == ZoneOperationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.zoneOperationMessage ?? localizations.errorOccurred),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoadingZones) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF781F)),
            );
          }

          if (state.zonesErrorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    state.zonesErrorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CouponsBloc>().add(
                        const LoadDeliveryZonesEvent(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF781F),
                    ),
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            );
          }

          if (state.deliveryZones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    color: Colors.grey.shade400,
                    size: 64,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    localizations.noCouponZonesYet,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    localizations.createZonesToRestrict,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: () => _showZoneDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(localizations.createZone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF781F),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CouponsBloc>().add(const LoadDeliveryZonesEvent());
            },
            color: const Color(0xFFFF781F),
            child: ListView.separated(
              padding: EdgeInsets.all(4.w),
              itemCount: state.deliveryZones.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final zone = state.deliveryZones[index];
                return _buildZoneCard(zone);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showZoneDialog(),
        backgroundColor: const Color(0xFFFF781F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildZoneCard(DeliveryZone zone) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showZoneDialog(zone: zone),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF781F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: const Color(0xFFFF781F),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showZoneDialog(zone: zone);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(zone);
                      }
                    },
                    itemBuilder: (context) {
                      final localizations = AppLocalizations.of(context)!;
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text(localizations.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                localizations.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              if (zone.description != null && zone.description!.isNotEmpty) ...[
                SizedBox(height: 1.5.h),
                Text(
                  zone.description!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              if (zone.hasLocation) ...[
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        size: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${zone.latitude!.toStringAsFixed(4)}, ${zone.longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (zone.radiusKm != null) ...[
                        SizedBox(width: 3.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF781F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${zone.radiusKm!.toStringAsFixed(1)} ${localizations.km}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFFFF781F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  void _showZoneDialog({DeliveryZone? zone}) {
    final isEditing = zone != null;
    final nameController = TextEditingController(text: zone?.name ?? '');
    final descController = TextEditingController(text: zone?.description ?? '');
    final latController = TextEditingController(
      text: zone?.latitude?.toString() ?? '',
    );
    final lngController = TextEditingController(
      text: zone?.longitude?.toString() ?? '',
    );
    final radiusController = TextEditingController(
      text: zone?.radiusKm?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        final localizations = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(isEditing ? localizations.editZone : localizations.createZone),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: localizations.zoneNameRequired,
                  hintText: localizations.zoneNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: localizations.description,
                  hintText: localizations.optionalDescription,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latController,
                      decoration: InputDecoration(
                        labelText: localizations.latitude,
                        hintText: localizations.latitudeHint,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*$'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: lngController,
                      decoration: InputDecoration(
                        labelText: localizations.longitude,
                        hintText: localizations.longitudeHint,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*$'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: radiusController,
                decoration: InputDecoration(
                  labelText: localizations.radiusKm,
                  hintText: localizations.radiusHint,
                  border: const OutlineInputBorder(),
                  suffixText: localizations.km,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.zoneNameIsRequired),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final lat = double.tryParse(latController.text.trim());
              final lng = double.tryParse(lngController.text.trim());
              final radius = double.tryParse(radiusController.text.trim());

              if (isEditing) {
                this.context.read<CouponsBloc>().add(
                  UpdateDeliveryZoneEvent(
                    id: zone.id,
                    name: name,
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                    latitude: lat,
                    longitude: lng,
                    radiusKm: radius,
                  ),
                );
              } else {
                this.context.read<CouponsBloc>().add(
                  CreateDeliveryZoneEvent(
                    name: name,
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                    latitude: lat,
                    longitude: lng,
                    radiusKm: radius,
                  ),
                );
              }

              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF781F),
            ),
            child: Text(isEditing ? localizations.update : localizations.create),
          ),
        ],
        );
      },
    );
  }

  void _showDeleteConfirmation(DeliveryZone zone) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final localizations = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(localizations.deleteZone),
          content: Text(localizations.deleteZoneConfirmation(zone.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CouponsBloc>().add(
                  DeleteDeliveryZoneEvent(id: zone.id),
                );
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(localizations.delete),
            ),
          ],
        );
      },
    );
  }
}
