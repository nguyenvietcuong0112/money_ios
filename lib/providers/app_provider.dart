import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:money_manager/models/transaction_model.dart';

class AppProvider with ChangeNotifier {
  Locale? _locale;
  String _currency;
  String _currencySymbol;

  List<TransactionModel> _transactions = [];

  Locale? get locale => _locale;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  List<TransactionModel> get transactions => _transactions;

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

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
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
