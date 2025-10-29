import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/app_localizations.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final Box<TransactionModel> transactionBox = Hive.box<TransactionModel>('transactions');

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('transactions')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context, appProvider.currencySymbol, localizations),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: transactionBox.listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }

          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final transaction = box.getAt(index)!;
              return ListTile(
                leading: Icon(transaction.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward),
                title: Text(transaction.title),
                subtitle: Text(transaction.category),
                trailing: Text(
                  '${appProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.amount > 0 ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, String currencySymbol, AppLocalizations localizations) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.translate('add_transaction')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: localizations.translate('title')),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: '${localizations.translate('amount')} ($currencySymbol)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: localizations.translate('category')),
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
                final newTransaction = TransactionModel(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  date: DateTime.now(),
                  category: categoryController.text,
                );
                transactionBox.add(newTransaction);
                Navigator.of(context).pop();
              },
              child: Text(localizations.translate('add')),
            ),
          ],
        );
      },
    );
  }
}
