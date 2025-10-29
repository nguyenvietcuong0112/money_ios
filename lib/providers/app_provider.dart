import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';

class AppProvider with ChangeNotifier {
  Locale? _locale;
  String _currency;
  String _currencySymbol;

  Locale? get locale => _locale;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;

  AppProvider({Locale? initialLocale, String? initialCurrency}) 
      : _locale = initialLocale,
        _currency = initialCurrency ?? 'USD',
        _currencySymbol = _getCurrencySymbol(initialCurrency ?? 'USD');

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setCurrency(String currencyCode) {
    _currency = currencyCode;
    _currencySymbol = _getCurrencySymbol(currencyCode);
    notifyListeners();
  }

  static String _getCurrencySymbol(String currencyCode) {
      try {
        Currency? currency = CurrencyService().findByCode(currencyCode);
        return currency?.symbol ?? '\$';
      } catch (e) {
        return '\$';
      }
  }
}
