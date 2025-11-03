import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    if (enteredAmount <= 0 || _selectedCategory == null || _selectedWallet == null) {
      return;
    }

    final transactionController = Get.find<TransactionController>();
    final walletController = Get.find<WalletController>();

    transactionController.addTransaction(
      _selectedCategory!.name,
      enteredAmount,
      _selectedDate,
      _selectedType,
      _selectedCategory!.iconPath,
      _selectedCategory!.colorValue,
      _selectedWallet!.id,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
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
              ),
              child: const Text('Add Transaction'),
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
        const Icon(Icons.attach_money, size: 30),
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
        const Text('\$', style: TextStyle(fontSize: 24)),
      ],
    );
  }

  Widget _buildDateField() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(DateFormat.yMMMd().format(_selectedDate)),
      trailing: const Icon(Icons.arrow_forward_ios),
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
      leading: const Icon(Icons.account_balance_wallet),
      title: Text(_selectedWallet?.name ?? 'Choose wallet'),
      trailing: const Icon(Icons.arrow_forward_ios),
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
      leading: const Icon(Icons.note),
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
