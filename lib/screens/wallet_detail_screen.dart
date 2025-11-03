import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:money_manager/screens/transaction_detail_screen.dart';

class WalletDetailScreen extends StatelessWidget {
  final Wallet wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    final AppController appController = Get.find();
    final WalletController walletController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name, style: AppTextStyles.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 4),
            Obx(() {
              final updatedWallet = walletController.wallets.firstWhere(
                (w) => w.id == wallet.id,
                orElse: () => wallet,
              );
              return Text(
                '${updatedWallet.balance.toStringAsFixed(0)} ${appController.currencySymbol}',
                style: AppTextStyles.heading1.copyWith(
                  color: updatedWallet.balance >= 0 ? Colors.green : Colors.red,
                ),
              );
            }),
            const SizedBox(height: 24.0),
            Text(
              'Transactions',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Obx(() {
                final walletTransactions = transactionController.transactions
                    .where((transaction) => transaction.walletId == wallet.id)
                    .toList();

                if (walletTransactions.isEmpty) {
                  return Center(
                      child: Text('No transactions for this wallet yet.',
                          style: AppTextStyles.body));
                }

                return ListView.builder(
                  itemCount: walletTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = walletTransactions[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        onTap: () => Get.to(
                            () => TransactionDetailScreen(transaction: transaction)),
                        leading: CircleAvatar(
                          backgroundColor:
                              Color(transaction.colorValue).withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(transaction.iconPath,
                                color: Color(transaction.colorValue)),
                          ),
                        ),
                        title: Text(transaction.title,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            DateFormat.yMMMd().format(transaction.date),
                            style: AppTextStyles.caption),
                        trailing: Text(
                          '${transaction.type == TransactionType.expense ? '-' : '+'}${transaction.amount.toStringAsFixed(0)} ${appController.currencySymbol}',
                          style: AppTextStyles.body.copyWith(
                            color: transaction.type == TransactionType.expense
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
