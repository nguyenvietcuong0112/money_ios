import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider with ChangeNotifier {
  final Box<Transaction> _transactionsBox = Hive.box<Transaction>('transactions');
  List<Transaction> _transactions = [];

  TransactionProvider() {
    _loadTransactions();
  }

  List<Transaction> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  void _loadTransactions() {
    _transactions = _transactionsBox.values.toList();
    notifyListeners();
  }

  void addTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type,
    String iconPath,
    int colorValue,
    String walletId,
  ) {
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
      type: type,
      iconPath: iconPath,
      colorValue: colorValue,
      walletId: walletId,
    );
    _transactionsBox.put(newTransaction.id, newTransaction);
    _loadTransactions();
  }

  void deleteTransaction(String transactionId) {
    _transactionsBox.delete(transactionId);
    _loadTransactions();
  }
}
