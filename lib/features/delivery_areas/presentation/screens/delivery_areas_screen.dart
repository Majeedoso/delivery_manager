import 'package:delivery_manager/core/utils/amounts.dart';
import 'package:delivery_manager/core/utils/error_message_mapper.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_bloc.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_event.dart';
import 'package:delivery_manager/features/delivery_areas/presentation/controller/delivery_areas_state.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The delivery zones: a customer can order only at a door inside a zone that
/// is on. The app had no page for them (decision 4 of manager_suite_report.md);
/// its other zones are the coupons'.
class DeliveryAreasScreen extends StatelessWidget {
  const DeliveryAreasScreen({super.key});

  static const _orange = Color(0xFFFF781F);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deliveryAreas),
        backgroundColor: isDark ? Colors.black : _orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: _orange,
        tooltip: l10n.addDeliveryArea,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<DeliveryAreasBloc, DeliveryAreasState>(
        listenWhen: (previous, current) =>
            current.actionFailure != null &&
            previous.actionFailure != current.actionFailure,
        listener: (context, state) {
          ErrorSnackBar.show(context, state.actionFailure);
          context.read<DeliveryAreasBloc>().add(
            const ClearDeliveryAreaFailureEvent(),
          );
        },
        builder: (context, state) {
          if (state.status == DeliveryAreasStatus.loading &&
              state.areas.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _orange),
            );
          }
          if (state.status == DeliveryAreasStatus.error) {
            return _Failure(message: state.errorMessage ?? '');
          }
          if (state.areas.isEmpty) {
            return _Empty(onAdd: () => _showForm(context));
          }
          return RefreshIndicator(
            color: _orange,
            onRefresh: () async => context.read<DeliveryAreasBloc>().add(
              const LoadDeliveryAreasEvent(),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: [
                Text(
                  l10n.deliveryAreasHelp,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                for (final area in state.areas) ...[
                  _AreaCard(
                    area: area,
                    busy: state.busyId == area.id,
                    onEdit: () => _showForm(context, area: area),
                    onDelete: () => _confirmDelete(context, area),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// The form for a new zone, or for [area].
  static void _showForm(BuildContext context, {DeliveryArea? area}) {
    final bloc = context.read<DeliveryAreasBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _AreaForm(
        area: area,
        onSave: (draft) => bloc.add(SaveDeliveryAreaEvent(draft)),
      ),
    );
  }

  static void _confirmDelete(BuildContext context, DeliveryArea area) {
    final bloc = context.read<DeliveryAreasBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.deleteDeliveryArea),
          content: Text(l10n.deleteDeliveryAreaConfirmation(area.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                bloc.add(DeleteDeliveryAreaEvent(area.id));
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}

class _AreaCard extends StatelessWidget {
  final DeliveryArea area;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AreaCard({
    required this.area,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.7);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    area.isActive ? Icons.location_on : Icons.location_off,
                    color: area.isActive ? DeliveryAreasScreen._orange : muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      area.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Semantics(
                    identifier: 'delivery_zone.switch',
                    container: true,
                    child: Switch(
                      value: area.isActive,
                      activeThumbColor: DeliveryAreasScreen._orange,
                      // While it is sent, a second tap would switch it back
                      onChanged: busy
                          ? null
                          : (_) => context.read<DeliveryAreasBloc>().add(
                              SwitchDeliveryAreaEvent(area.id),
                            ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (choice) =>
                        choice == 'edit' ? onEdit() : onDelete(),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 36, end: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.isActive
                          ? l10n.deliveryAreaOn
                          : l10n.deliveryAreaOff,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: area.isActive ? Colors.green.shade700 : muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (area.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        area.description!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${area.latitude.toStringAsFixed(4)}, '
                      '${area.longitude.toStringAsFixed(4)} · '
                      '${area.radiusKm.toStringAsFixed(1)} ${l10n.km}',
                      textDirection: TextDirection.ltr,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A new zone, or [area] changed: a name, a centre and a radius (0.1 to 100
/// km, as the server takes it).
class _AreaForm extends StatefulWidget {
  final DeliveryArea? area;
  final ValueChanged<DeliveryAreaDraft> onSave;

  const _AreaForm({this.area, required this.onSave});

  @override
  State<_AreaForm> createState() => _AreaFormState();
}

class _AreaFormState extends State<_AreaForm> {
  late final _name = TextEditingController(text: widget.area?.name);
  late final _description = TextEditingController(
    text: widget.area?.description,
  );
  late final _latitude = TextEditingController(
    text: widget.area?.latitude.toString(),
  );
  late final _longitude = TextEditingController(
    text: widget.area?.longitude.toString(),
  );
  late final _radius = TextEditingController(
    text: widget.area?.radiusKm.toString(),
  );
  String? _problem;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _latitude,
      _longitude,
      _radius,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save(AppLocalizations l10n) {
    final name = _name.text.trim();
    final latitude = parseTypedAmount(_latitude.text);
    final longitude = parseTypedAmount(_longitude.text);
    final radius = parseTypedAmount(_radius.text);
    final problem = name.isEmpty
        ? l10n.zoneNameIsRequired
        : latitude == null ||
              longitude == null ||
              latitude.abs() > 90 ||
              longitude.abs() > 180
        ? l10n.coordinatesInvalid
        : radius == null || radius < 0.1 || radius > 100
        ? l10n.radiusOutOfRange
        : null;
    if (problem != null) {
      setState(() => _problem = problem);
      return;
    }

    final description = _description.text.trim();
    widget.onSave(
      DeliveryAreaDraft(
        id: widget.area?.id,
        name: name,
        description: description.isEmpty ? null : description,
        latitude: latitude!,
        longitude: longitude!,
        radiusKm: radius!,
        isActive: widget.area?.isActive ?? true,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const number = TextInputType.numberWithOptions(decimal: true, signed: true);

    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.area == null ? l10n.addDeliveryArea : l10n.editDeliveryArea,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.zoneNameRequired,
              hintText: l10n.zoneNameHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.description,
              hintText: l10n.optionalDescription,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _latitude,
            keyboardType: number,
            decoration: InputDecoration(
              labelText: l10n.latitude,
              hintText: l10n.latitudeHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _longitude,
            keyboardType: number,
            decoration: InputDecoration(
              labelText: l10n.longitude,
              hintText: l10n.longitudeHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _radius,
            keyboardType: number,
            decoration: InputDecoration(
              labelText: l10n.radiusKm,
              hintText: l10n.radiusHint,
              suffixText: l10n.km,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_problem != null) ...[
            const SizedBox(height: 12),
            Text(
              _problem!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => _save(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: DeliveryAreasScreen._orange,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.area == null ? l10n.create : l10n.update),
        ),
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  final String message;

  const _Failure({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              message.isEmpty
                  ? l10n.errorOccurred
                  : ErrorMessageMapper.getUserFriendlyMessage(message, l10n),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<DeliveryAreasBloc>().add(
                const LoadDeliveryAreasEvent(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAreasScreen._orange,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onAdd;

  const _Empty({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDeliveryAreasYet,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addDeliveryArea),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAreasScreen._orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
