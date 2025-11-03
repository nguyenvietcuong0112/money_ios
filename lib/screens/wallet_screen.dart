import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/screens/add_wallet_screen.dart';
import 'package:money_manager/screens/wallet_detail_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final WalletController walletController = Get.find();
    final AppController appController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FEF7), // Light green-ish background
      appBar: AppBar(
        title: Text(localizations?.translate('my_wallet') ?? 'My Wallet', style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Obx(() {
              return _buildTotalBalanceCard(context, walletController.totalBalance, localizations, appController);
            }),
            const SizedBox(height: 24.0),

            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: walletController.wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = walletController.wallets[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(wallet.iconPath),
                          ),
                        ),
                        title: Text(wallet.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${wallet.balance.toStringAsFixed(0)} ${appController.currencySymbol}',
                          style: AppTextStyles.body.copyWith(
                            color: wallet.balance < 0 ? Colors.red : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Get.to(() => WalletDetailScreen(wallet: wallet));
                        },
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: () {
                Get.to(() => const AddWalletScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E9E54), // Dark green
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
              child: Text(
                '+ ${localizations?.translate('add_wallet') ?? 'Add Wallet'}',
                style: AppTextStyles.button.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double totalBalance, AppLocalizations? localizations, AppController appController) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFD7F5DD), // Light green
              child: Icon(Icons.account_balance, size: 30, color: Colors.green),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.translate('total_balance') ?? 'Total Balance',
                  style: AppTextStyles.subtitle.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${totalBalance.toStringAsFixed(0)} ${appController.currencySymbol}',
                  style: AppTextStyles.heading2.copyWith(
                        color: totalBalance < 0 ? Colors.red : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
