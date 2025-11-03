import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class WalletController extends GetxController {
  final Box<Wallet> _walletsBox = Hive.box<Wallet>('wallets');
  // Sử dụng RxList để GetX có thể "lắng nghe" sự thay đổi
  final RxList<Wallet> wallets = <Wallet>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWallets();
  }

  // Getter cho tổng số dư, tự động tính toán lại khi `wallets` thay đổi
  double get totalBalance => wallets.fold(0, (sum, item) => sum + item.balance);

  void _loadWallets() {
    wallets.value = _walletsBox.values.toList();
  }

  void setupInitialWallets(BuildContext context) {
    if (wallets.isEmpty) {
      const String placeholderIcon = 'assets/icons/ic_food.png';

      final initialWallets = [
        Wallet(
          id: const Uuid().v4(),
          name: 'Credit',
          balance: 0,
          iconPath: placeholderIcon,
        ),
        Wallet(
          id: const Uuid().v4(),
          name: 'E-Wallet',
          balance: 0,
          iconPath: placeholderIcon,
        ),
        Wallet(
          id: const Uuid().v4(),
          name:   'Bank',
          balance: 0,
          iconPath: placeholderIcon,
        ),
        Wallet(
          id: const Uuid().v4(),
          name:  'Cash',
          balance: 0,
          iconPath: placeholderIcon,
        ),
      ];

      for (var wallet in initialWallets) {
        _walletsBox.put(wallet.id, wallet);
      }
      _loadWallets(); // Tải lại sau khi thiết lập ban đầu
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
    // Tối ưu: Chỉ cần thêm vào RxList
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
        image: wallet.image,
      );
      _walletsBox.put(walletId, updatedWallet);
      // Tối ưu: Cập nhật phần tử trong RxList, GetX sẽ tự động nhận diện
      wallets[walletIndex] = updatedWallet;
    }
  }

  void deleteWallet(String walletId) {
    _walletsBox.delete(walletId);
    // Tối ưu: Chỉ cần xóa khỏi RxList
    wallets.removeWhere((wallet) => wallet.id == walletId);
  }

  Wallet? getWalletById(String id) {
    // Ưu tiên tìm trong list đang có để có tốc độ nhanh hơn
    try {
      return wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      // Nếu không có thì tìm trong box, đề phòng trường hợp chưa đồng bộ
      return _walletsBox.get(id);
    }
  }
}
