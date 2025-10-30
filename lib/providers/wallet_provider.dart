
import 'package:flutter/material.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class WalletProvider with ChangeNotifier {
  final List<Wallet> _wallets = [
    Wallet(id: '1', name: 'Credit', balance: 0, icon: Icons.credit_card),
    Wallet(id: '2', name: 'E-Wallet', balance: -120, icon: Icons.account_balance_wallet),
    Wallet(id: '3', name: 'Bank', balance: -40, icon: Icons.account_balance),
    Wallet(id: '4', name: 'Cash', balance: 0, icon: Icons.money),
  ];

  List<Wallet> get wallets => _wallets;

  double get totalBalance => _wallets.fold(0, (sum, item) => sum + item.balance);

  void addWallet(String name, double initialBalance, IconData icon) {
    final newWallet = Wallet(
      id: const Uuid().v4(),
      name: name,
      balance: initialBalance,
      icon: icon,
    );
    _wallets.add(newWallet);
    notifyListeners();
  }

  void updateBalance(String walletId, double amount) {
    final walletIndex = _wallets.indexWhere((wallet) => wallet.id == walletId);
    if (walletIndex != -1) {
      _wallets[walletIndex] = Wallet(
        id: _wallets[walletIndex].id,
        name: _wallets[walletIndex].name,
        balance: _wallets[walletIndex].balance + amount,
        icon: _wallets[walletIndex].icon,
      );
      notifyListeners();
    }
  }

  Wallet? getWalletById(String id) {
    try {
      return _wallets.firstWhere((wallet) => wallet.id == id);
    } catch (e) {
      return null;
    }
  }
}
