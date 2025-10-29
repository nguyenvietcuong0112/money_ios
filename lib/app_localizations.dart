
import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // For simplicity, we'll just use a map. In a real app, you'd load a JSON file.
    _localizedStrings = {
      'en': {
        'home': 'Home',
        'transactions': 'Transactions',
        'budget': 'Budget',
        'statistics': 'Statistics',
        'settings': 'Settings',
        'balance': 'Balance',
        'income': 'Income',
        'expense': 'Expense',
        'dark_mode': 'Dark Mode',
        'language': 'Language',
        'currency': 'Currency',
        'add_transaction': 'Add Transaction',
        'title': 'Title',
        'amount': 'Amount',
        'category': 'Category',
        'cancel': 'Cancel',
        'add': 'Add',
        'no_budgets_set': 'No budgets set yet.',
        'set_budget': 'Set Budget',
        'set': 'Set',
      },
      'vi': {
        'home': 'Trang chủ',
        'transactions': 'Giao dịch',
        'budget': 'Ngân sách',
        'statistics': 'Thống kê',
        'settings': 'Cài đặt',
        'balance': 'Số dư',
        'income': 'Thu nhập',
        'expense': 'Chi tiêu',
        'dark_mode': 'Chế độ tối',
        'language': 'Ngôn ngữ',
        'currency': 'Tiền tệ',
        'add_transaction': 'Thêm giao dịch',
        'title': 'Tiêu đề',
        'amount': 'Số tiền',
        'category': 'Danh mục',
        'cancel': 'Hủy',
        'add': 'Thêm',
        'no_budgets_set': 'Chưa có ngân sách nào được đặt.',
        'set_budget': 'Đặt ngân sách',
        'set': 'Đặt',
      },
      'fr': {
        'home': 'Accueil',
        'transactions': 'Transactions',
        'budget': 'Budget',
        'statistics': 'Statistiques',
        'settings': 'Paramètres',
        'balance': 'Solde',
        'income': 'Revenu',
        'expense': 'Dépense',
        'dark_mode': 'Mode sombre',
        'language': 'Langue',
        'currency': 'Devise',
        'add_transaction': 'Ajouter une transaction',
        'title': 'Titre',
        'amount': 'Montant',
        'category': 'Catégorie',
        'cancel': 'Annuler',
        'add': 'Ajouter',
        'no_budgets_set': 'Aucun budget n\'a encore été défini.',
        'set_budget': 'Définir le budget',
        'set': 'Définir',
      }
    }[locale.languageCode]!;
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
