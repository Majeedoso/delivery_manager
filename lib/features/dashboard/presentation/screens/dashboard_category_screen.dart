import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/utils/error_message_mapper.dart';
import 'package:delivery_manager/core/widgets/error_snackbar.dart';
import 'package:delivery_manager/features/dashboard/presentation/setting_texts.dart';
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
      appBar: AppBar(title: Text(settingCategoryName(l10n, widget.category))),
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
                      state.errorMessage == null
                          ? l10n.failedToLoadSettings
                          : ErrorMessageMapper.getUserFriendlyMessage(
                              state.errorMessage,
                              l10n,
                            ),
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
                      settingName(l10n, setting.key),
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
                          settingTypeName(l10n, setting.type),
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

  void _showInfoDialog(BuildContext context, AppDashboard setting) {
    final l10n = AppLocalizations.of(context)!;
    final info = settingTexts(l10n, setting.key);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(settingName(l10n, setting.key)),
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
                  info.help,
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
              _buildInfoRow(
                context,
                l10n.type,
                settingTypeName(l10n, setting.type),
              ),
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
                  settingName(l10n, setting.key),
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
      title: Text(
        settingName(AppLocalizations.of(context)!, widget.setting.key),
      ),
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
                settingTypeName(
                  AppLocalizations.of(context)!,
                  widget.setting.type,
                ),
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
            // A text may be emptied (the address, to hide it); a number may not
            if (newValue.isEmpty && widget.setting.type != 'string') return;
            Navigator.of(context).pop();
            widget.onConfirm(newValue);
          },
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
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

