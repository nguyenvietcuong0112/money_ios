import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';

class AppProvider with ChangeNotifier {
  Locale _locale = const Locale('en', '');
  String _currency = 'USD';
  String _currencySymbol = '\$';

  Locale get locale => _locale;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setCurrency(String currencyCode) {
    _currency = currencyCode;
    _currencySymbol = _getCurrencySymbol(currencyCode);
    notifyListeners();
  }

  String _getCurrencySymbol(String currencyCode) {
    try {
      Currency? currency = CurrencyService().findByCode(currencyCode);
      return currency?.symbol ?? '\$';
    } catch (e) {
      return '\$';
    }
  }
}
