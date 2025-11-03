import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final Rx<Locale?> _locale = (null as Locale?).obs;
  final RxString _currency = 'USD'.obs;

  Locale? get locale => _locale.value;
  String get currency => _currency.value;
  String get currencySymbol => _getCurrencySymbol(currency);

  AppController({Locale? initialLocale, String? initialCurrency}) {
    if (initialLocale != null) {
      _locale.value = initialLocale;
    }
    if (initialCurrency != null) {
      _currency.value = initialCurrency;
    }
  }

  void setLocale(Locale locale) async {
    _locale.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  void setCurrency(String currency) async {
    _currency.value = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
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
