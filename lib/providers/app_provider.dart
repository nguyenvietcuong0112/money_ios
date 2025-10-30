
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  Locale? _locale;
  String _currency;

  Locale? get locale => _locale;
  String get currency => _currency;
  String get currencySymbol => _getCurrencySymbol(_currency);

  AppProvider({Locale? initialLocale, String? initialCurrency})
      : _locale = initialLocale,
        _currency = initialCurrency ?? 'USD';

  void setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  void setCurrency(String currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    notifyListeners();
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'GBP':
        return '£';
      case 'VND':
        return '₫';
      default:
        return '\$';
    }
  }
}
