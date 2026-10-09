/// A phone number as written among the app's own words: always left to right
/// (a Unicode isolate), so an Arabic page shows "+213 555 12 34 56" and not
/// "213 555 12 34 56+" (the "+" is a neutral character and took the
/// right-to-left side).
String phoneText(String phone) => phone.isEmpty ? phone : '\u2066$phone\u2069';
