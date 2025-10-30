import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final IconData icon;
  final Color color;
  final String walletId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
    required this.color,
    required this.walletId,
  });
}
