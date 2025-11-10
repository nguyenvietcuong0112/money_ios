import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class WalletController extends GetxController {
  final Box<Wallet> _walletsBox = Hive.box<Wallet>('wallets');
  final RxList<Wallet> wallets = <Wallet>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWallets();
  }

  double get totalBalance => wallets.fold(0, (sum, item) => sum + item.balance);

  void _loadWallets() {
    wallets.value = _walletsBox.values.toList();
  }

  void setupInitialWallets(BuildContext context) {
    if (wallets.isEmpty) {
      final initialWallets = [
        Wallet(
          id: const Uuid().v4(),
          name: 'Saving',
          balance: 0,
          iconPath: 'assets/icons/ic_saving.svg',
        ),
        Wallet(
          id: const Uuid().v4(),
          name:  'Cash',
          balance: 0,
          iconPath: 'assets/icons/ic_cash.svg',
        ),
        Wallet(
          id: const Uuid().v4(),
          name:   'Bank',
          balance: 0,
          iconPath: 'assets/icons/ic_bank.svg',
        ),
        Wallet(
          id: const Uuid().v4(),
          name: 'Credit',
          balance: 0,
          iconPath: 'assets/icons/ic_credit.svg',
        ),
      ];

      for (var wallet in initialWallets) {
        _walletsBox.put(wallet.id, wallet);
      }
      _loadWallets();
    }
  }

  void addWallet(String name, double initialBalance, String iconPath) {
    final newWallet = Wallet(
      id: const Uuid().v4(),
      name: name,
      balance: initialBalance,
      iconPath: iconPath,
    );
    _walletsBox.put(newWallet.id, newWallet);
    wallets.add(newWallet);
  }

  void updateBalance(String walletId, double amount) {
    final walletIndex = wallets.indexWhere((w) => w.id == walletId);
    if (walletIndex != -1) {
      final wallet = wallets[walletIndex];
      final updatedWallet = Wallet(
        id: wallet.id,
        name: wallet.name,
        balance: wallet.balance + amount,
        iconPath: wallet.iconPath,
      );
      _walletsBox.put(walletId, updatedWallet);
      wallets[walletIndex] = updatedWallet;
    }
  }

  void deleteWallet(String walletId) {
    _walletsBox.delete(walletId);
    wallets.removeWhere((wallet) => wallet.id == walletId);
  }

  Wallet? getWalletById(String id) {
    try {
      return wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      return _walletsBox.get(id);
    }
  }
}
