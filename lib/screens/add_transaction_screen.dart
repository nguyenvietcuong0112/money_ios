import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:get/get.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  Wallet? _selectedWallet;

  // Updated categories list with iconPath and colorValue
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

  void _submitData() {
    final double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (enteredAmount <= 0) {
      Get.snackbar('Invalid Input', 'Amount must be greater than zero.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedCategory == null) {
      Get.snackbar('Invalid Input', 'Please select a category.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedWallet == null) {
      Get.snackbar('Invalid Input', 'Please select a wallet.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final transactionController = Get.find<TransactionController>();
    final walletController = Get.find<WalletController>();

    transactionController.addTransaction(
      note: _noteController.text, // Correctly pass the note
      amount: enteredAmount,
      date: _selectedDate,
      type: _selectedType,
      categoryName: _selectedCategory!.name, // Correctly pass the category name
      iconPath: _selectedCategory!.iconPath,
      colorValue: _selectedCategory!.colorValue,
      walletId: _selectedWallet!.id,
    );

    walletController.updateBalance(
      _selectedWallet!.id,
      _selectedType == TransactionType.income ? enteredAmount : -enteredAmount,
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    // Set a default wallet if none is selected
    if (_selectedWallet == null && walletController.wallets.isNotEmpty) {
      _selectedWallet = walletController.wallets.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction', style: AppTextStyles.title),
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
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)
                )
              ),
              child: Text('Add Transaction', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }

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
          style: AppTextStyles.body.copyWith(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
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
            style: AppTextStyles.heading1,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: AppTextStyles.heading1.copyWith(color: Colors.grey)
            ),
          ),
        ),
        Text('\$', style: AppTextStyles.heading1.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDateField() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, color: Colors.grey),
      title: Text(DateFormat.yMMMd().format(_selectedDate), style: AppTextStyles.body),
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
      title: Text(_selectedWallet?.name ?? 'Choose wallet', style: AppTextStyles.body),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (wallets.isEmpty) {
            Get.snackbar('No Wallets', 'Please add a wallet first.', snackPosition: SnackPosition.BOTTOM);
            return;
        }
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView.builder(
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return ListTile(
                  leading: Image.asset(wallet.iconPath, width: 24, height: 24),
                  title: Text(wallet.name, style: AppTextStyles.body),
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
        style: AppTextStyles.body,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Note something...',
          hintStyle: AppTextStyles.body.copyWith(color: Colors.grey)
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.title),
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
            final isSelected = _selectedCategory?.name == category.name;
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
                    Text(category.name, textAlign: TextAlign.center, style: AppTextStyles.caption),
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
