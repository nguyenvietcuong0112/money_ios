import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  late Category _selectedCategory;
  late Wallet _selectedWallet;

  final List<Category> _categories = [
    Category(name: 'Food & Dr...', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.orange.value),
    Category(name: 'Household', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.blue.value),
    Category(name: 'Shopping', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.purple.value),
    Category(name: 'House', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.green.value),
    Category(name: 'Travel', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.indigo.value),
    Category(name: 'Sport', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.red.value),
    Category(name: 'Cosmetics', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.pink.value),
    Category(name: 'Water Bill', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.lightBlue.value),
    Category(name: 'Electric Bill', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.yellow.value),
    Category(name: 'Phone', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.grey.value),
    Category(name: 'Education', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.brown.value),
    Category(name: 'Medical', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.redAccent.value),
  ];

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    _amountController = TextEditingController(text: transaction.amount.toString());
    // Correct: `title` is now the note field.
    _noteController = TextEditingController(text: transaction.title);
    _selectedDate = transaction.date;
    _selectedType = transaction.type;

    // Correct: Find category by `categoryName`
    _selectedCategory = _categories.firstWhere(
      (cat) => cat.name == transaction.categoryName,
      orElse: () => _categories[0], // Fallback to the first category
    );

    final walletController = Get.find<WalletController>();
    _selectedWallet = walletController.wallets.firstWhere(
      (wallet) => wallet.id == transaction.walletId,
      orElse: () => walletController.wallets.isNotEmpty
          ? walletController.wallets[0]
          : Wallet(id: 'fallback', name: 'Unknown', iconPath: '', balance: 0),
    );
  }

   void _confirmDelete() {
    Get.defaultDialog(
      title: "Delete Transaction",
      middleText: "Are you sure you want to delete this transaction?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        final transactionController = Get.find<TransactionController>();
        final walletController = Get.find<WalletController>();
        final transaction = widget.transaction;

        // 1. Calculate amount to revert from wallet balance
        final amountToRevert = transaction.type == TransactionType.income 
            ? -transaction.amount 
            : transaction.amount;
        
        walletController.updateBalance(transaction.walletId, amountToRevert);

        // 2. Delete the transaction from Hive
        transactionController.deleteTransaction(transaction.id);

        Get.back(); // Close dialog
        Get.back(); // Go back from detail screen
      },
    );
  }

  void _updateTransaction() {
    final double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (enteredAmount <= 0) {
      Get.snackbar("Invalid Amount", "Please enter a valid amount.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final transactionController = Get.find<TransactionController>();
    final walletController = Get.find<WalletController>();
    final originalTransaction = widget.transaction;

    // --- Wallet Balance Update Logic ---
    // 1. Calculate the impact of the *original* transaction
    final originalImpact = originalTransaction.type == TransactionType.income 
        ? originalTransaction.amount 
        : -originalTransaction.amount;

    // 2. Calculate the impact of the *new* transaction
    final newImpact = _selectedType == TransactionType.income 
        ? enteredAmount 
        : -enteredAmount;

    // 3. Find the difference to apply to the wallet
    // This handles changes in amount, type (income/expense), and even wallet
    final balanceChange = newImpact - originalImpact;

    // If the wallet itself has changed, we need two updates
    if (_selectedWallet.id != originalTransaction.walletId) {
        // Revert from old wallet
        walletController.updateBalance(originalTransaction.walletId, -originalImpact);
        // Apply to new wallet
        walletController.updateBalance(_selectedWallet.id, newImpact);
    } else {
        // If same wallet, just apply the net change
        walletController.updateBalance(_selectedWallet.id, balanceChange);
    }

    // Create the updated transaction using copyWith
    final updatedTransaction = originalTransaction.copyWith(
      title: _noteController.text.trim(),
      amount: enteredAmount,
      date: _selectedDate,
      type: _selectedType,
      categoryName: _selectedCategory.name,
      iconPath: _selectedCategory.iconPath,
      colorValue: _selectedCategory.colorValue,
      walletId: _selectedWallet.id,
    );

    // Update the transaction in the controller
    transactionController.updateTransaction(updatedTransaction);

    Get.back(); // Go back from detail screen
    Get.snackbar("Success", "Transaction updated successfully.", snackPosition: SnackPosition.BOTTOM);
  }


  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
            tooltip: 'Delete Transaction',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeToggle(),
            const SizedBox(height: 20),
            _buildAmountField(),
            const SizedBox(height: 20),
            _buildDateField(),
            const Divider(),
            _buildWalletField(walletController.wallets),
            const Divider(),
            _buildNoteField(),
            const Divider(),
            const SizedBox(height: 20),
            _buildCategoryGrid(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _updateTransaction,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)
                )
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Re-used Widgets from AddTransactionScreen ---

  Widget _buildTypeToggle() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeButton('Expense', TransactionType.expense),
            _buildTypeButton('Income', TransactionType.income),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, TransactionType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (type == TransactionType.expense ? Colors.red : Colors.green) : Colors.transparent,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Row(
      children: [
        const Icon(Icons.attach_money, size: 30, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
            ),
          ),
        ),
        const Text('\$', style: TextStyle(fontSize: 24, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDateField() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, color: Colors.grey),
      title: Text(DateFormat.yMMMd().format(_selectedDate)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

  Widget _buildWalletField(List<Wallet> wallets) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.account_balance_wallet, color: Colors.grey),
      title: Text(_selectedWallet.name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView.builder(
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return ListTile(
                  leading: Image.asset(wallet.iconPath, width: 24, height: 24),
                  title: Text(wallet.name),
                  onTap: () {
                    setState(() {
                      _selectedWallet = wallet;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNoteField() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.note, color: Colors.grey),
      title: TextField(
        controller: _noteController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Note something...',
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory.name == category.name;
            final categoryColor = Color(category.colorValue);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? categoryColor.withAlpha(77) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                  border: isSelected ? Border.all(color: categoryColor, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(category.iconPath, width: 30, height: 30, color: categoryColor),
                    const SizedBox(height: 5),
                    Text(category.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
