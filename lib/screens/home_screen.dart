import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final Box<TransactionModel> transactionBox = Hive.box<TransactionModel>('transactions');

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('home')),
      ),
      body: ValueListenableBuilder(
        valueListenable: transactionBox.listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          double totalIncome = 0;
          double totalExpense = 0;

          for (var transaction in box.values) {
            if (transaction.amount > 0) {
              totalIncome += transaction.amount;
            } else {
              totalExpense += transaction.amount.abs();
            }
          }

          double balance = totalIncome - totalExpense;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${localizations.translate('balance')}: ${appProvider.currencySymbol}${balance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard(context, localizations.translate('income'), totalIncome, Colors.green, appProvider.currencySymbol),
                    _buildSummaryCard(context, localizations.translate('expense'), totalExpense, Colors.red, appProvider.currencySymbol),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount, Color color, String currencySymbol) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '$currencySymbol${amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}
