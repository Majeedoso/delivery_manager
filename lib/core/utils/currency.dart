import 'package:delivery_manager/l10n/app_localizations.dart';

enum Currency {
  dzd,
}

extension CurrencyX on Currency {
  String get code {
    switch (this) {
      case Currency.dzd:
        return 'DZD';
    }
  }
}

/// The dinar in the manager's language: "دج" in Arabic, as the statistics and
/// coupon pages write it (decision 7 of manager_suite_report.md: the bank alone
/// wrote "DZD" in Arabic).
extension LocalDinars on AppLocalizations {
  /// [amount] written as the server and the bank's models write it
  /// ("1,234.50 DZD"), with the dinar in the manager's language. The cents
  /// stay.
  String dinars(String amount) =>
      amount.replaceAll(Currency.dzd.code, currency);
}
