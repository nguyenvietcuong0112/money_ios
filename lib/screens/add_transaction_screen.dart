import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:get/get.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/models/category_data.dart';
import 'package:money_manager/widgets/transaction_type_toggle.dart';

import '../controllers/app_controller.dart';

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

  @override
  void initState() {
    super.initState();
    final walletController = Get.find<WalletController>();
    if (walletController.wallets.isNotEmpty) {
      _selectedWallet = walletController.wallets.first;
    }
    // Set a default category for expense
    if (_selectedType == TransactionType.expense) {
      _selectedCategory = defaultCategories.first;
    }
  }

  void _submitData() {
    final String amountText = _amountController.text.replaceAll(r'$', '');
    final double enteredAmount = double.tryParse(amountText) ?? 0.0;

    if (enteredAmount <= 0) {
      Get.snackbar('Invalid Input', 'Amount must be positive',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedCategory == null) {
      Get.snackbar('Invalid Input', 'Please select a category',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedWallet == null) {
      Get.snackbar('Invalid Input', 'Please select a wallet',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final transactionController = Get.find<TransactionController>();
    final walletController = Get.find<WalletController>();

    transactionController.addTransaction(
      note: _noteController.text,
      amount: enteredAmount,
      date: _selectedDate,
      type: _selectedType,
      categoryName: _selectedCategory!.name,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('add_transaction'.tr,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionTypeToggle(
              onChanged: (type) {
                setState(() {
                  _selectedType = type;
                  // Reset category and set default for the new type
                  if (type == TransactionType.expense) {
                    _selectedCategory = defaultCategories.first;
                  } else {
                    _selectedCategory = defaultIncomeCategories.first;
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Amount'),
            _buildAmountField(),
            const SizedBox(height: 24),
             _buildSectionTitle('Day Trading'),
            _buildDateField(),
            const SizedBox(height: 24),
            _buildSectionTitle('Wallet'),
            _buildWalletField(),
            const SizedBox(height: 24),
            _buildSectionTitle('Note'),
            _buildNoteField(),
            const SizedBox(height: 24),
            _buildSectionTitle('Category'),
            const SizedBox(height: 10),
            _buildCategoryGrid(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: const Color(0xFF4A80F0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
              ),
              child:
                  Text('SAVE', style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    final AppController appController = Get.find();
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixText: appController.currencySymbol,
        prefixStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        hintText: '0',
        hintStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: const Color(0xFF4A80F0), width: 2),
        ),
      ),
      onChanged: (value) {
        // Simple currency formatting
        String newText = '\$${value.replaceAll(r'$', '')}';
        if (_amountController.text != newText) {
          _amountController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
          );
        }
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                style: const TextStyle(fontSize: 16)),
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF4A80F0)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletField() {
    final walletController = Get.find<WalletController>();
    return InkWell(
      onTap: () {
        if (walletController.wallets.isEmpty) {
          Get.snackbar('No Wallets', 'Please add a wallet first.',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView.builder(
              itemCount: walletController.wallets.length,
              itemBuilder: (context, index) {
                final wallet = walletController.wallets[index];
                return ListTile(
                  leading: Image.asset(wallet.iconPath, width: 30, height: 30),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            if (_selectedWallet != null)
              Image.asset(_selectedWallet!.iconPath, width: 30, height: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedWallet?.name ?? 'Choose Wallet',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Enter transaction description',
        hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF4A80F0), width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _selectedType == TransactionType.expense
        ? defaultCategories
        : defaultIncomeCategories;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory?.name == category.name;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF3E70FD) : Color(0xFFF0F3FA),
                    width: isSelected ? 3 : 1,
                  ),
                   boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                ),
                child: SvgPicture.asset(
                  category.iconPath,
                  width: 50,
                  height: 50,
                  // The color of the SVG can be controlled via its properties or a ColorFilter
                  // color: isSelected ? Colors.white : Color(category.colorValue),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
