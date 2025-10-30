import 'package:flutter/material.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class WalletDetailScreen extends StatelessWidget {
  final Wallet wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final walletTransactions = transactionProvider.transactions
        .where((transaction) => transaction.walletId == wallet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '\$${wallet.balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: wallet.balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: walletTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = walletTransactions[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(transaction.icon, color: transaction.color),
                      title: Text(transaction.title),
                      subtitle: Text(transaction.date.toString()),
                      trailing: Text(
                        '\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: transaction.type == 'expense' ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
