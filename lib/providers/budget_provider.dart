
import 'package:flutter/material.dart';
import 'package:money_manager/models/budget_model.dart';

class BudgetProvider with ChangeNotifier {
  final List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => _budgets;

  void addBudget(BudgetModel budget) {
    _budgets.add(budget);
    notifyListeners();
  }
}
