import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fails when a text or an icon on screen can't be seen against what is
/// painted behind it: its contrast (WCAG's ratio, 1 to 21) is below
/// [minimum]. The default catches what can't be read at all (white on white
/// is 1, light grey on white 1.3), not the app's orange labels on cream (about
/// 2, its design): WCAG asks 4.5.
///
/// The app follows the phone's theme, so a page drawn with a fixed white box
/// shows dark mode's light text white on white. Pump the page with
/// `themeMode: ThemeMode.dark` and call this. What is behind a text is the
/// nearest box painted under it that hides what is below (more than half
/// opaque): a Container's or a DecoratedBox's colour, a Material's (a card,
/// a sheet, the page), a filled text field's fill.
void expectReadable(WidgetTester tester, {double minimum = 1.5}) {
  final fills = <RenderObject, Color>{};
  for (final element in find.byType(InputDecorator).evaluate()) {
    final decoration = (element.widget as InputDecorator).decoration;
    if (decoration.filled != true) continue;
    final theme = Theme.of(element);
    final fill =
        decoration.fillColor ??
        theme.inputDecorationTheme.fillColor ??
        theme.colorScheme.surfaceContainerHighest;
    fills[element.renderObject!] = fill;
  }
  for (final element in find.byType(ColoredBox).evaluate()) {
    fills[element.renderObject!] = (element.widget as ColoredBox).color;
  }

  final unreadable = <String>[];
  void check(String text, Color? colour, RenderObject from) {
    if (text.trim().isEmpty || colour == null) return;
    final behind = _behind(from, fills);
    if (behind == null) return;
    // A see-through colour shows what is behind it
    final seen = Color.alphaBlend(colour, behind);
    final ratio = contrastOf(seen, behind);
    if (ratio < minimum) {
      final what = _isIcon(text)
          ? 'an icon'
          : '"${text.length > 40 ? '${text.substring(0, 40)}...' : text}"';
      unreadable.add(
        '$what: ${_hex(seen)} on ${_hex(behind)} (${ratio.toStringAsFixed(1)})',
      );
    }
  }

  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject as RenderParagraph;
    if (!paragraph.attached || !paragraph.hasSize || paragraph.size.isEmpty) {
      continue;
    }
    check(paragraph.text.toPlainText(), paragraph.text.style?.color, paragraph);
  }
  for (final element in find.byType(EditableText).evaluate()) {
    final field = element.widget as EditableText;
    check(field.controller.text, field.style.color, element.renderObject!);
  }

  expect(unreadable, isEmpty, reason: 'texts that can\'t be read');
}

/// WCAG's contrast ratio between two colours: 1 (the same) to 21 (black on
/// white). 3 is the least for large text, 4.5 for body text.
double contrastOf(Color a, Color b) {
  final la = a.withValues(alpha: 1).computeLuminance();
  final lb = b.withValues(alpha: 1).computeLuminance();
  final (light, dark) = la > lb ? (la, lb) : (lb, la);
  return (light + 0.05) / (dark + 0.05);
}

Color? _behind(RenderObject from, Map<RenderObject, Color> fills) {
  for (RenderObject? node = from.parent; node != null; node = node.parent) {
    Color? colour = fills[node];
    if (colour == null) {
      if (node is RenderDecoratedBox) {
        final decoration = node.decoration;
        if (decoration is BoxDecoration && decoration.gradient == null) {
          colour = decoration.color;
        } else if (decoration is ShapeDecoration &&
            decoration.gradient == null) {
          colour = decoration.color;
        }
      } else if (node is RenderPhysicalShape) {
        colour = node.color;
      } else if (node is RenderPhysicalModel) {
        colour = node.color;
      }
    }
    if (colour != null && colour.a > 0.5) return colour;
  }
  return null;
}

/// An icon is one character of a font's private area (Material Icons).
bool _isIcon(String text) =>
    text.runes.length == 1 &&
    text.runes.first >= 0xE000 &&
    text.runes.first <= 0xF8FF;

String _hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
