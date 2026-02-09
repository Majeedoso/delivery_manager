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

class CurrencyUtils {
  static Currency fromCode(String? code) {
    switch ((code ?? '').toUpperCase()) {
      case 'DZD':
        return Currency.dzd;
      default:
        return Currency.dzd;
    }
  }

  static String normalizeCode(String? code) => fromCode(code).code;
}
