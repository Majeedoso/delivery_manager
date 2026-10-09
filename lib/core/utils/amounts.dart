/// Reads an amount of money (whole dinars) the way the server may send it: a
/// number (`2455`, `2455.0`), a numeric string (`"2455.00"`), or a string
/// formatted for display with thousands separators (`"2,455.00"`, PHP's
/// `number_format`). Anything else reads as 0.
///
/// The orders the driver is offered come formatted: read as plain numbers, every
/// order of 1,000 DA or more showed 0 DA to collect.
int parseAmount(Object? value) {
  if (value is num) return value.round();
  if (value is! String) return 0;
  final digits = value.replaceAll(RegExp(r'[,\s\u00A0\u202F]'), '');
  return double.tryParse(digits)?.round() ?? 0;
}

/// Reads an amount as a person types it: "12,5" and "12.5" are the same number
/// (a French keyboard writes the comma, an Arabic one "٫"), spaces are
/// ignored, and Arabic digits count. Null when it is not a number: the form
/// refused "12,5" as an invalid amount.
double? parseTypedAmount(String? text) {
  if (text == null) return null;

  final buffer = StringBuffer();
  for (final rune in text.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660); // ٠ to ٩
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0); // ۰ to ۹
    } else if (rune == 0x2C || rune == 0x066B) {
      buffer.write('.'); // "," and "٫"
    } else if (rune != 0x20 && rune != 0xA0 && rune != 0x202F) {
      buffer.writeCharCode(rune);
    }
  }

  return double.tryParse(buffer.toString());
}
