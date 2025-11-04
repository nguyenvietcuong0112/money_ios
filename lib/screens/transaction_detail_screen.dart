import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/models/category_data.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';

import '../controllers/app_controller.dart';

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

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    _amountController = TextEditingController(text: transaction.amount.toString());
    _noteController = TextEditingController(text: transaction.title);
    _selectedDate = transaction.date;
    _selectedType = transaction.type;

    _selectedCategory = defaultCategories.firstWhere(
      (cat) => cat.name == transaction.categoryName,
      orElse: () => defaultCategories[0],
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
      title: "delete_transaction".tr,
      titleStyle: AppTextStyles.title.copyWith(color: Get.isDarkMode ? Colors.white : Colors.black),
      middleText: "are_you_sure_delete".tr,
      middleTextStyle: AppTextStyles.body.copyWith(color: Get.isDarkMode ? Colors.white : Colors.black),
      textConfirm: "delete".tr,
      textCancel: "cancel".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        final transactionController = Get.find<TransactionController>();
        final walletController = Get.find<WalletController>();
        final transaction = widget.transaction;

        final amountToRevert = transaction.type == TransactionType.income 
            ? -transaction.amount 
            : transaction.amount;
        
        walletController.updateBalance(transaction.walletId, amountToRevert);

        transactionController.deleteTransaction(transaction.id);

        Get.back();
        Get.back();
      },
    );
  }

  void _updateTransaction() {
    final double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (enteredAmount <= 0) {
      Get.snackbar("invalid_amount".tr, "please_enter_valid_amount".tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final transactionController = Get.find<TransactionController>();
    final walletController = Get.find<WalletController>();
    final originalTransaction = widget.transaction;

    final originalImpact = originalTransaction.type == TransactionType.income 
        ? originalTransaction.amount 
        : -originalTransaction.amount;

    final newImpact = _selectedType == TransactionType.income 
        ? enteredAmount 
        : -enteredAmount;

    final balanceChange = newImpact - originalImpact;

    if (_selectedWallet.id != originalTransaction.walletId) {
        walletController.updateBalance(originalTransaction.walletId, -originalImpact);
        walletController.updateBalance(_selectedWallet.id, newImpact);
    } else {
        walletController.updateBalance(_selectedWallet.id, balanceChange);
    }

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

    transactionController.updateTransaction(updatedTransaction);

    Get.back();
    Get.snackbar("Success", "success_update".tr, snackPosition: SnackPosition.BOTTOM);
  }


  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('transaction_detail'.tr, style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
            tooltip: 'delete_transaction'.tr,
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
              child: Text('save_changes'.tr, style: AppTextStyles.button),
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
            _buildTypeButton('expense'.tr, TransactionType.expense),
            _buildTypeButton('income'.tr, TransactionType.income),
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
    final AppController appController = Get.find();
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
        Text(appController.currencySymbol, style: AppTextStyles.heading1.copyWith(color: Colors.grey)),
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
      title: Text(_selectedWallet.name, style: AppTextStyles.body),
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
          hintText: 'note_something'.tr,
          hintStyle: AppTextStyles.body.copyWith(color: Colors.grey)
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('category'.tr, style: AppTextStyles.title),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: defaultCategories.length,
          itemBuilder: (context, index) {
            final category = defaultCategories[index];
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
                    Text(category.name.tr, textAlign: TextAlign.center, style: AppTextStyles.caption),
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
