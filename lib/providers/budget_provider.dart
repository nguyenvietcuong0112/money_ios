import 'package:flutter/material.dart';
import 'package:money_manager/models/models.dart';

class BudgetProvider with ChangeNotifier {
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      category: 'Salary',
      amount: 5000,
      date: DateTime.now(),
      type: 'income',
    ),
    Transaction(
      id: 't2',
      category: 'Groceries',
      amount: 150,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'expense',
    ),
    Transaction(
      id: 't3',
      category: 'Rent',
      amount: 1200,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'expense',
    ),
    Transaction(
      id: 't4',
      category: 'Freelance',
      amount: 300,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'income',
    ),
  ];

  final List<BudgetModel> _budgets = [];

  List<Transaction> get transactions => _transactions;
  List<BudgetModel> get budgets => _budgets;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void addBudget(BudgetModel budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  Map<DateTime, List<Transaction>> getTransactionsByMonth(DateTime month) {
    final Map<DateTime, List<Transaction>> events = {};
    for (final transaction in _transactions) {
      if (transaction.date.month == month.month && transaction.date.year == month.year) {
        final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(transaction);
      }
    }
    return events;
  }

  Map<String, double> getDailySummary(List<Transaction> transactions) {
    double income = 0;
    double expense = 0;
    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
    return {'income': income, 'expense': expense};
  }

  Map<String, double> getMonthlySummary(DateTime month) {
    double income = 0;
    double expense = 0;
    for (final transaction in _transactions) {
      if (transaction.date.month == month.month && transaction.date.year == month.year) {
        if (transaction.type == 'income') {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
      }
    }
    return {'income': income, 'expense': expense};
  }
}
