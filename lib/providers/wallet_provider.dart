import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class WalletProvider with ChangeNotifier {
  final Box<Wallet> _walletsBox = Hive.box<Wallet>('wallets');
  List<Wallet> _wallets = [];

  WalletProvider() {
    _loadWallets();
  }

  List<Wallet> get wallets => _wallets;

  double get totalBalance => _wallets.fold(0, (sum, item) => sum + item.balance);

  void _loadWallets() {
    _wallets = _walletsBox.values.toList();
    notifyListeners();
  }

  void addWallet(String name, double initialBalance, IconData icon) {
    final newWallet = Wallet(
      id: const Uuid().v4(),
      name: name,
      balance: initialBalance,
      icon: icon,
    );
    _walletsBox.put(newWallet.id, newWallet);
    _loadWallets();
  }

  void updateBalance(String walletId, double amount) {
    final wallet = _walletsBox.get(walletId);
    if (wallet != null) {
      final updatedWallet = Wallet(
        id: wallet.id,
        name: wallet.name,
        balance: wallet.balance + amount,
        icon: wallet.icon,
        image: wallet.image,
      );
      _walletsBox.put(walletId, updatedWallet);
      _loadWallets();
    }
  }

  void deleteWallet(String walletId) {
    _walletsBox.delete(walletId);
    _loadWallets();
  }

  Wallet? getWalletById(String id) {
    return _walletsBox.get(id);
  }
}
