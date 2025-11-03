import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final Rx<Locale?> _locale = (null as Locale?).obs;
  final RxString _currencyCode = 'USD'.obs;
  final RxString _currencySymbol = '\$'.obs;

  Locale? get locale => _locale.value;
  String get currency => _currencyCode.value; // Maintained for compatibility
  String get currencySymbol => _currencySymbol.value;

  AppController({
    Locale? initialLocale,
    String? initialCurrencyCode,
    String? initialCurrencySymbol,
  }) {
    if (initialLocale != null) {
      _locale.value = initialLocale;
    }
    if (initialCurrencyCode != null) {
      _currencyCode.value = initialCurrencyCode;
      _currencySymbol.value = initialCurrencySymbol ??
          CurrencyService().findByCode(initialCurrencyCode)?.symbol ??
          '\$';
    }
  }

  // Hàm mới để thay đổi ngôn ngữ
  void changeLocale(Locale newLocale) async {
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);
    await prefs.setString('countryCode', newLocale.countryCode ?? '');
  }

  void setCurrency(String currencyCode, String currencySymbol) async {
    _currencyCode.value = currencyCode;
    _currencySymbol.value = currencySymbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCode', currencyCode);
    await prefs.setString('currencySymbol', currencySymbol);
    await prefs.remove('currency');
  }
}
