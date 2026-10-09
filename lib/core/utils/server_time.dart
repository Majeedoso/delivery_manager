/// A time the server sent, as the phone's clock shows it.
///
/// The server keeps UTC. Its ISO texts say so ("2026-09-30T10:40:00+00:00",
/// "...Z"); its "2026-09-30 10:40:00" texts carry no zone and are UTC too.
/// Shown as they came, every time in the app was the server's: one hour
/// early in Algeria. A date alone ("2026-09-30") is a day, and stays that day.
DateTime parseServerTime(String value) {
  final parsed = DateTime.parse(value);
  if (parsed.isUtc) return parsed.toLocal();
  if (value.trim().length <= 10) return parsed;
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  ).toLocal();
}

/// [parseServerTime] for a value that may be missing or unreadable.
DateTime? tryParseServerTime(Object? value) {
  if (value is! String || DateTime.tryParse(value) == null) return null;
  return parseServerTime(value);
}
