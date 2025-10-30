import 'package:flutter/material.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:money_manager/providers/wallet_provider.dart';
import 'package:money_manager/screens/add_wallet_screen.dart';
import 'package:money_manager/screens/wallet_detail_screen.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('my_wallet') ?? 'My Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(50),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.account_balance_wallet, color: Colors.white),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.translate('total_balance') ?? 'Total Balance',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '\$${walletProvider.totalBalance.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: walletProvider.totalBalance >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.arrow_downward, color: Colors.white),
                          ),
                          const SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations?.translate('income') ?? 'Income',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '\$${transactionProvider.totalIncome.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.arrow_upward, color: Colors.white),
                          ),
                          const SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations?.translate('expense') ?? 'Expense',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '\$${transactionProvider.totalExpense.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: ListView.builder(
                itemCount: walletProvider.wallets.length,
                itemBuilder: (context, index) {
                  final wallet = walletProvider.wallets[index];
                  return Dismissible(
                    key: Key(wallet.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      walletProvider.deleteWallet(wallet.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${wallet.name} deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // walletProvider.addWallet(wallet.name, wallet.balance, wallet.icon);
                            },
                          ),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Icon(wallet.icon, size: 40),
                        title: Text(wallet.name),
                        subtitle: Text('\$${wallet.balance.toStringAsFixed(2)}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WalletDetailScreen(wallet: wallet)),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddWalletScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(localizations?.translate('add_wallet') ?? 'Add Wallet'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // full width
              ),
            ),
          ],
        ),
      ),
    );
  }
}
