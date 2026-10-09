/// The week begins on Sunday and ends on Saturday, in every language (the
/// owner's rule). The server says the same in `LocalTime::WEEK_STARTS_ON`.
///
/// Whatever counts or draws a week reads its first day here: "this week" on
/// every page ([startOfWeek]) and the first column of a calendar
/// (`WeekMaterialLocalizations`).
const int firstDayOfWeek = DateTime.sunday;

/// The first day of [day]'s week, at midnight.
DateTime startOfWeek(DateTime day) => DateTime(
  day.year,
  day.month,
  day.day - (day.weekday - firstDayOfWeek) % DateTime.daysPerWeek,
);
