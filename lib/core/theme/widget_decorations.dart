import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/theme/theme.dart';

/// Centralized widget decorations and styles for reusable UI components
/// This file contains styling for specific widget types used across the app
class WidgetDecorations {
  /// Get the date picker container decoration
  /// Used for both "From" and "To" date picker containers in order screens
  static BoxDecoration getDatePickerContainerDecoration(BuildContext context, {double elevation = 2.0}) {
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor ?? 
                     Theme.of(context).colorScheme.secondaryContainer;
    return BoxDecoration(
      color: fillColor,
      borderRadius: MaterialTheme.getBorderRadiusMedium(),
      border: Border.all(
        color: Theme.of(context).colorScheme.inversePrimary,
        width: 1.0,
      ),
      boxShadow: elevation > 0 ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
      ] : null,
    );
  }

  /// Get the standard date picker label text style ("From", "To")
  static TextStyle getDatePickerLabelStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark 
        ? Theme.of(context).colorScheme.inversePrimary 
        : Colors.black;
    return Theme.of(context).textTheme.labelMedium?.copyWith(
      color: labelColor,
    ) ?? TextStyle(
      fontSize: 12.sp,
      color: labelColor,
    );
  }

  /// Get the standard date picker date text style (the actual date value)
  static TextStyle getDatePickerDateStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    ) ?? TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Get the standard date picker container padding
  static EdgeInsets getDatePickerContainerPadding() {
      return EdgeInsets.symmetric(
        horizontal: MaterialTheme.getSpacing('paddingHorizontalSmall').w,
        vertical: MaterialTheme.getSpacing('paddingHorizontalSmall').w,
      );
  }

  /// Get a styled checkbox widget with consistent styling
  /// This includes the Container with border, Transform.scale, and all checkbox properties
  static Widget getStyledCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Transform.scale(
      scale: MaterialTheme.getSpacing('checkboxScale'),
      alignment: Alignment.center,
      child: Container(
        width: MaterialTheme.getSpacing('checkboxSize').w,
        height: MaterialTheme.getSpacing('checkboxSize').w,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: MaterialTheme.getSpacing('borderWidthSmall'),
          ),
          borderRadius: MaterialTheme.getBorderRadiusSmall(),
          color: Colors.white,
        ),
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          fillColor: WidgetStateProperty.all(Colors.transparent),
          checkColor: Colors.black,
          side: BorderSide.none,
        ),
      ),
    );
  }

  /// Get a styled info card container with consistent styling
  /// Used in Profile, Settings, and Statistics screens
  /// This creates a Card with ListTile that matches the TextField fill color
  static Widget getInfoCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? labelColor,
    Color? valueColor,
    VoidCallback? onTap,
    Widget? trailing,
    double? height, // Optional height override
    TextDirection? valueTextDirection, // Optional text direction for value (e.g., LTR for emails)
  }) {
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor ?? 
                     Theme.of(context).colorScheme.secondaryContainer;
    final borderColor = Theme.of(context).colorScheme.inversePrimary;
    
    // If height is specified, use Row layout (for profile page)
    if (height != null) {
      final cardContent = Card(
        margin: EdgeInsets.only(bottom: MaterialTheme.getSpacing('cardMarginBottom')),
        color: fillColor,
        shape: RoundedRectangleBorder(
          borderRadius: MaterialTheme.getBorderRadiusMedium(),
          side: BorderSide(
            color: borderColor,
            width: 0.2.w,
          ),
        ),
        child: SizedBox(
          height: height.h,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MaterialTheme.getSpacing('listTilePaddingHorizontal').w,
              vertical: MaterialTheme.getSpacing('listTilePaddingVertical').h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  icon,
                  color: iconColor ?? (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.inversePrimary
                      : Colors.black),
                  size: 24.sp,
                ),
                SizedBox(width: 4.w),
                // Text (label and value)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: labelColor ?? Colors.grey,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (value.isNotEmpty)
                        Text(
                          value,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: valueColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: valueTextDirection,
                        ),
                    ],
                  ),
                ),
                // Trailing arrow
                if (trailing != null)
                  trailing
                else if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios, 
                    size: MaterialTheme.getSpacing('iconTrailingSmall').sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Colors.black,
                  ),
              ],
            ),
          ),
        ),
      );
      
      // Wrap in InkWell or GestureDetector if onTap is provided
      if (onTap != null) {
        return InkWell(
          onTap: onTap,
          borderRadius: MaterialTheme.getBorderRadiusMedium(),
          child: cardContent,
        );
      }
      
      return cardContent;
    }
    
    // Default ListTile layout (for settings, statistics, etc.)
    final listTile = ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: MaterialTheme.getSpacing('listTilePaddingHorizontal').w,
        vertical: MaterialTheme.getSpacing('listTilePaddingVertical').h,
      ),
      visualDensity: VisualDensity.standard,
      isThreeLine: value.length > 30, // Allow three lines for long emails
      titleAlignment: value.isEmpty ? ListTileTitleAlignment.center : ListTileTitleAlignment.top,
      leading: Icon(
        icon,
        color: iconColor ?? (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.inversePrimary
            : Colors.black),
        size: 24.sp,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: labelColor ?? Colors.grey,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: value.isNotEmpty ? Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.normal,
          color: valueColor,
        ),
        maxLines: null, // Allow unlimited lines when flexible
        overflow: TextOverflow.visible,
        textDirection: valueTextDirection,
      ) : null,
      trailing: trailing ?? (onTap != null 
        ? Icon(
            Icons.arrow_forward_ios, 
            size: MaterialTheme.getSpacing('iconTrailingSmall').sp,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.inversePrimary
                : Colors.black,
          ) 
        : null),
      onTap: onTap,
    );
    
    return Card(
      margin: EdgeInsets.only(bottom: MaterialTheme.getSpacing('cardMarginBottom')),
      color: fillColor,
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusMedium(),
        side: BorderSide(
          color: borderColor,
          width: 0.2.w,
        ),
      ),
      child: listTile,
    );
  }

  /// Get a styled action card container with consistent styling
  /// Used for action buttons in Profile screen (Edit Profile, Change Email, etc.)
  static Widget getActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor ?? 
                     Theme.of(context).colorScheme.secondaryContainer;
    final borderColor = Theme.of(context).colorScheme.inversePrimary;
    
    return Card(
      margin: EdgeInsets.only(bottom: MaterialTheme.getSpacing('cardMarginBottom')),
      color: fillColor,
      shape: RoundedRectangleBorder(
        borderRadius: MaterialTheme.getBorderRadiusMedium(),
        side: BorderSide(
          color: borderColor,
          width: 0.2.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: MaterialTheme.getBorderRadiusMedium(),
          child: SizedBox(
            height: MaterialTheme.getSpacing('profileCardHeight').h,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MaterialTheme.getSpacing('listTilePaddingHorizontal').w,
                vertical: MaterialTheme.getSpacing('listTilePaddingVertical').h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    icon,
                    color: iconColor ?? (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Colors.blue),
                    size: 24.sp,
                  ),
                  SizedBox(width: 4.w),
                  // Text
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Trailing arrow
                  Icon(
                    Icons.arrow_forward_ios, 
                    size: MaterialTheme.getSpacing('iconTrailingSmall').sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

