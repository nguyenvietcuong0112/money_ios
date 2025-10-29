import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(BuildContext context, double amount, String currency) {
  final format = NumberFormat.currency(locale: Localizations.localeOf(context).toString(), symbol: currency, decimalDigits: 2);
  return format.format(amount);
}
