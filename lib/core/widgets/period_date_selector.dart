import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';
import 'package:delivery_manager/core/theme/theme.dart';
import 'package:delivery_manager/core/theme/widget_decorations.dart';
import 'package:delivery_manager/core/utils/date_formatter.dart';

/// Complete period and date range selector widget
/// 
/// This widget provides a reusable component for selecting time periods
/// (all, day, week, month, year, dateRange) with conditional date range pickers
/// that appear when "dateRange" is selected.
/// 
/// Used across multiple features (Statistics, Orders) to maintain consistency.
class PeriodDateSelector extends StatelessWidget {
  /// Currently selected period (all, day, week, month, year, dateRange)
  final String selectedPeriod;
  
  /// Start date (nullable, used when period is 'dateRange')
  final DateTime? dateFrom;
  
  /// End date (nullable, used when period is 'dateRange')
  final DateTime? dateTo;
  
  /// Callback when period changes
  /// Receives the newly selected period value
  final void Function(String period) onPeriodChanged;
  
  /// Callback when start date is selected
  /// Receives the current dateFrom value (may be null)
  final Future<void> Function(DateTime?) onDateFromSelected;
  
  /// Callback when end date is selected
  /// Receives the current dateTo value (may be null)
  final Future<void> Function(DateTime?) onDateToSelected;
  
  /// Optional: Custom period options (defaults to all standard options)
  /// Format: [{'value': 'period', 'label': 'Localized Label'}]
  final List<Map<String, String>>? customPeriodOptions;
  
  /// Whether to include "all" option (defaults to true)
  final bool includeAllOption;
  
  /// Minimum selectable date for date pickers (defaults to DateTime(2020))
  final DateTime? firstDate;
  
  /// Maximum selectable date for date pickers (defaults to DateTime.now())
  final DateTime? lastDate;
  
  /// Spacing between period selector and date range pickers
  /// Defaults to 2.h
  final double? spacingBetween;

  const PeriodDateSelector({
    super.key,
    required this.selectedPeriod,
    required this.dateFrom,
    required this.dateTo,
    required this.onPeriodChanged,
    required this.onDateFromSelected,
    required this.onDateToSelected,
    this.customPeriodOptions,
    this.includeAllOption = true,
    this.firstDate,
    this.lastDate,
    this.spacingBetween,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = spacingBetween ?? 2.h;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeriodSelector(context),
        if (selectedPeriod == 'dateRange') ...[
          SizedBox(height: spacing),
          _buildDateRangeSelectors(context),
        ],
      ],
    );
  }

  /// Builds the period selector dropdown button
  Widget _buildPeriodSelector(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor ?? 
                     Theme.of(context).colorScheme.secondaryContainer;
    final borderColor = Theme.of(context).colorScheme.inversePrimary;
    
    final periodOptions = customPeriodOptions ?? [
      if (includeAllOption) {'value': 'all', 'label': localizations.all},
      {'value': 'day', 'label': localizations.day},
      {'value': 'week', 'label': localizations.week},
      {'value': 'month', 'label': localizations.month},
      {'value': 'year', 'label': localizations.year},
      {'value': 'dateRange', 'label': localizations.dateRange},
    ];
    
    return DropdownButton2<String>(
      value: selectedPeriod,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: borderColor,
          size: 28.sp,
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      dropdownStyleData: DropdownStyleData(
        // Increased height to show all 6 items without scrolling with extra space
        // 6 items * ~7.h each = ~42.h + extra padding for better visibility
        maxHeight: 60.h,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: MaterialTheme.getBorderRadiusMedium(),
          border: Border.all(
            color: borderColor,
            width: 0.2.w,
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: MaterialTheme.getBorderRadiusMedium().topLeft,
          thickness: WidgetStateProperty.all(0.6.w),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        // Increased height to give more space for text
        height: 6.h,
        // Increased horizontal padding to prevent text cutoff
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 0,
        ),
      ),
      buttonStyleData: ButtonStyleData(
        padding: WidgetDecorations.getDatePickerContainerPadding(),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: MaterialTheme.getBorderRadiusMedium(),
          border: Border.all(
            color: borderColor,
            width: 0.2.w,
          ),
        ),
      ),
      items: periodOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option['value'],
          child: Text(
            option['label']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        );
      }).toList(),
      onChanged: (String? selectedValue) {
        if (selectedValue != null) {
          onPeriodChanged(selectedValue);
        }
      },
    );
  }

  /// Builds the date range selectors (From/To) that appear when "dateRange" is selected
  Widget _buildDateRangeSelectors(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            context: context,
            label: localizations.from,
            date: dateFrom,
            onTap: () => onDateFromSelected(dateFrom),
          ),
        ),
        SizedBox(width: 2.h),
        Expanded(
          child: _buildDatePicker(
            context: context,
            label: localizations.to,
            date: dateTo,
            onTap: () => onDateToSelected(dateTo),
          ),
        ),
      ],
    );
  }

  /// Builds a single date picker container (From or To)
  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(1.w),
        child: Container(
          padding: WidgetDecorations.getDatePickerContainerPadding(),
          decoration: WidgetDecorations.getDatePickerContainerDecoration(
            context,
            elevation: 1.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WidgetDecorations.getDatePickerLabelStyle(context),
                  ),
                  Text(
                    DateFormatter.formatDate(context, date),
                    style: WidgetDecorations.getDatePickerDateStyle(context),
                  ),
                ],
              ),
              Icon(
                Icons.calendar_today,
                size: 22.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

