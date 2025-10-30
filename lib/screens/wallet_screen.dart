import 'package:flutter/material.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/providers/wallet_provider.dart';
import 'package:money_manager/screens/add_wallet_screen.dart';
import 'package:money_manager/screens/wallet_detail_screen.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FEF7), // Light green-ish background
      appBar: AppBar(
        title: Text(localizations?.translate('my_wallet') ?? 'My Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Total Balance Card
            _buildTotalBalanceCard(context, walletProvider.totalBalance, localizations),
            const SizedBox(height: 24.0),

            // Wallets List
            Expanded(
              child: ListView.builder(
                itemCount: walletProvider.wallets.length,
                itemBuilder: (context, index) {
                  final wallet = walletProvider.wallets[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      leading: CircleAvatar(
                        backgroundColor: (wallet.icon.codePoint == Icons.credit_card.codePoint)
                            ? Colors.blue.shade100
                            : (wallet.icon.codePoint == Icons.account_balance_wallet.codePoint)
                                ? Colors.orange.shade100
                                : (wallet.icon.codePoint == Icons.account_balance.codePoint)
                                    ? Colors.blue.shade200
                                    : Colors.green.shade100,
                        child: Icon(wallet.icon, color: Colors.black54),
                      ),
                      title: Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${wallet.balance.toStringAsFixed(0)} \$',
                        style: TextStyle(
                          color: wallet.balance < 0 ? Colors.red : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WalletDetailScreen(wallet: wallet)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Add Wallet Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddWalletScreen()),
                );
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double totalBalance, AppLocalizations? localizations) {
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${totalBalance.toStringAsFixed(0)} \$',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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