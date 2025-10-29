
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/providers/budget_provider.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/screens/add_budget_screen.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final budgets = budgetProvider.budgets;
    final transactions = appProvider.transactions;
    final currencySymbol = appProvider.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
      ),
      body: budgets.isEmpty
          ? const Center(child: Text('No budgets set yet.'))
          : ListView.builder(
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final expenses = transactions
                    .where((t) => t.isExpense && t.category == budget.category)
                    .map((t) => t.amount.abs())
                    .fold(0.0, (prev, amount) => prev + amount);
                final progress = (expenses / budget.amount).clamp(0.0, 1.0);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress > 0.8 ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$currencySymbol${expenses.toStringAsFixed(2)} / $currencySymbol${budget.amount.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
