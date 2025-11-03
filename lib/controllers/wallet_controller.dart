import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class WalletController extends GetxController {
  final Box<Wallet> _walletsBox = Hive.box<Wallet>('wallets');
  final RxList<Wallet> _wallets = <Wallet>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWallets();
  }

  List<Wallet> get wallets => _wallets;

  double get totalBalance =>
      _wallets.fold(0, (sum, item) => sum + item.balance);

  void _loadWallets() {
    _wallets.value = _walletsBox.values.toList();
  }

  void setupInitialWallets(BuildContext context) {
    if (_wallets.isEmpty) {
      final localizations = AppLocalizations.of(context)!;
      const String placeholderIcon = 'assets/icons/ic_food.png';

      final initialWallets = [
        Wallet(
          id: const Uuid().v4(),
          name: localizations.translate('credit') ?? 'Credit',
          balance: 0,
          iconPath: placeholderIcon,
        ),
        Wallet(
          id: const Uuid().v4(),
          name: localizations.translate('e_wallet') ?? 'E-Wallet',
          balance: 0,
          iconPath: placeholderIcon,
        ),
        Wallet(
          id: const Uuid().v4(),
          name: localizations.translate('bank') ?? 'Bank',
          balance: 0,
          iconPath: placeholderIcon,
        ),
        Wallet(
          id: const Uuid().v4(),
          name: localizations.translate('cash') ?? 'Cash',
          balance: 0,
          iconPath: placeholderIcon,
        ),
      ];

      for (var wallet in initialWallets) {
        _walletsBox.put(wallet.id, wallet);
      }
      _loadWallets(); // Reload wallets after creation
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
    _loadWallets();
  }

  void updateBalance(String walletId, double amount) {
    final wallet = _walletsBox.get(walletId);
    if (wallet != null) {
      final updatedWallet = Wallet(
        id: wallet.id,
        name: wallet.name,
        balance: wallet.balance + amount,
        iconPath: wallet.iconPath,
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
