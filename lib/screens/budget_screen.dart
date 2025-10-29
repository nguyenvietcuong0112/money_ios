import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/models/budget_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/app_localizations.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final Box<BudgetModel> budgetBox = Hive.box<BudgetModel>('budgets');
  final Box<TransactionModel> transactionBox = Hive.box<TransactionModel>('transactions');

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('budget')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context, appProvider.currencySymbol, localizations),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: budgetBox.listenable(),
        builder: (context, Box<BudgetModel> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text(localizations.translate('no_budgets_set')));
          }

          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final budget = box.getAt(index)!;
              final expenses = transactionBox.values
                  .where((t) => t.category == budget.category && t.amount < 0)
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
                        '${appProvider.currencySymbol}${expenses.toStringAsFixed(2)} / ${appProvider.currencySymbol}${budget.amount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, String currencySymbol, AppLocalizations localizations) {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.translate('set_budget')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: localizations.translate('category')),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: '${localizations.translate('amount')} ($currencySymbol)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                final newBudget = BudgetModel(
                  category: categoryController.text,
                  amount: double.parse(amountController.text),
                );
                budgetBox.add(newBudget);
                Navigator.of(context).pop();
              },
              child: Text(localizations.translate('set')),
            ),
          ],
        );
      },
    );
  }
}
