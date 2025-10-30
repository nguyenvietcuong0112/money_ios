import 'package:flutter/material.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  void addTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type,
    IconData icon,
    Color color,
    String walletId,
  ) {
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
      type: type,
      icon: icon,
      color: color,
      walletId: walletId,
    );
    _transactions.add(newTransaction);
    notifyListeners();
  }
}
