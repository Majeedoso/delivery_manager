/// The backend's rule for a new password
/// (`Password::min(8)->mixedCase()->numbers()->symbols()` on sign-up and on
/// the change-password endpoint), so the app refuses exactly what the server
/// would refuse, and nothing it would accept.
class PasswordRules {
  PasswordRules._();

  /// Counted in characters (code points), like the server counts them.
  static const int minLength = 8;

  static final RegExp _lowercase = RegExp(r'\p{Ll}', unicode: true);
  static final RegExp _uppercase = RegExp(r'\p{Lu}', unicode: true);
  static final RegExp _number = RegExp(r'\p{N}', unicode: true);

  /// Laravel counts any punctuation mark, symbol or space as a symbol,
  /// so "#", "." or "_" are as good as "@".
  static final RegExp _symbol = RegExp(r'[\p{Z}\p{S}\p{P}]', unicode: true);

  static bool isLongEnough(String password) =>
      password.runes.length >= minLength;

  /// An upper case and a lower case letter, a number and a symbol.
  static bool isComplex(String password) =>
      _lowercase.hasMatch(password) &&
      _uppercase.hasMatch(password) &&
      _number.hasMatch(password) &&
      _symbol.hasMatch(password);
}
