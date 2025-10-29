
import 'package:flutter/material.dart';
import 'package:money_manager/screens/add_transaction_screen.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final transactions = appProvider.transactions;
    final currencySymbol = appProvider.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: Icon(
                    transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    color: transaction.isExpense ? Colors.red : Colors.green,
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(DateFormat.yMd().add_jm().format(transaction.date)),
                  trailing: Text(
                    '${currencySymbol}${transaction.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
