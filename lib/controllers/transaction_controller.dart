import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class TransactionController extends GetxController {
  final Box<Transaction> _transactionBox = Hive.box<Transaction>('transactions');
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
    // Lắng nghe các thay đổi từ box để cập nhật UI tự động
    _transactionBox.watch().listen((event) {
      // Chạy lại _loadTransactions bất cứ khi nào có thay đổi
      final allTransactions = _transactionBox.values.toList();
      // Sắp xếp theo ngày, giao dịch mới nhất lên đầu
      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      transactions.assignAll(allTransactions);
    });
    // Tải dữ liệu lần đầu
    final initialTransactions = _transactionBox.values.toList();
    initialTransactions.sort((a, b) => b.date.compareTo(a.date));
    transactions.assignAll(initialTransactions);
  }

  void addTransaction({
    required String note,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required String categoryName,
    required String iconPath,
    required int colorValue,
    required String walletId,
  }) {
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      title: note, // title is now the note
      amount: amount,
      date: date,
      type: type,
      categoryName: categoryName,
      iconPath: iconPath,
      colorValue: colorValue,
      walletId: walletId,
    );
    _transactionBox.put(newTransaction.id, newTransaction);
    // Không cần .add() nữa vì watch() sẽ tự cập nhật
  }

  void updateTransaction(Transaction transaction) {
    _transactionBox.put(transaction.id, transaction);
    // Không cần cập nhật list thủ công nữa
  }

  void deleteTransaction(String transactionId) {
    _transactionBox.delete(transactionId);
    // Không cần .removeWhere() nữa
  }
}
