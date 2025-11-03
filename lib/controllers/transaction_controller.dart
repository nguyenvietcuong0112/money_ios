import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class TransactionController extends GetxController {
  final Box<Transaction> _transactionsBox = Hive.box<Transaction>('transactions');
  // Sử dụng RxList để GetX có thể "lắng nghe" sự thay đổi
  final RxList<Transaction> transactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
  }

  double get totalIncome => transactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  void _loadTransactions() {
    // Gán giá trị cho RxList, nó sẽ tự động thông báo cho các listener (như Obx)
    transactions.value = _transactionsBox.values.toList();
  }

  void addTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type,
    String iconPath,
    int colorValue,
    String walletId,
  ) {
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
      type: type,
      iconPath: iconPath,
      colorValue: colorValue,
      walletId: walletId,
    );
    _transactionsBox.put(newTransaction.id, newTransaction);
    // Chỉ cần thêm vào RxList, Obx sẽ tự động cập nhật UI
    transactions.add(newTransaction);
  }

  void deleteTransaction(String transactionId) {
    _transactionsBox.delete(transactionId);
    // Chỉ cần xóa khỏi RxList, Obx sẽ tự động cập nhật UI
    transactions.removeWhere((transaction) => transaction.id == transactionId);
  }
}
