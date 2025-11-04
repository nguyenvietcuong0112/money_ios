import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/models/category_data.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:money_manager/widgets/custom_toggle_button.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  final Function(int) onScreenChanged;

  const StatisticsScreen({super.key, required this.onScreenChanged});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isMonthSelected = true;
  DateTime _selectedDate = DateTime.now();
  Wallet? _selectedWallet;
  int _selectedChartTabIndex = 0; // 0 for Expense, 1 for Income

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('report'.tr, style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            children: [
              CustomToggleButton(
                isMonthSelected: _isMonthSelected,
                onMonthSelected: () => setState(() => _isMonthSelected = true),
                onYearSelected: () => setState(() => _isMonthSelected = false),
              ),
              const SizedBox(height: 24.0),
              _buildFilters(),
              const SizedBox(height: 24.0),
              _buildSummary(),
              const SizedBox(height: 24.0),
              _buildChartTabs(),
              const SizedBox(height: 16.0),
              _buildChartAndLegend(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilters() {
    final WalletController walletController = Get.find();
    final List<Wallet?> walletItems = [null, ...walletController.wallets];

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isMonthSelected ? _showMonthYearPicker : _showYearPicker,
            child: _buildDropdownContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isMonthSelected
                        ? DateFormat('MM/yyyy').format(_selectedDate)
                        : DateFormat('yyyy').format(_selectedDate),
                    style: AppTextStyles.body,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdownContainer(
            child: DropdownButton<Wallet>(
              isExpanded: true,
              underline: const SizedBox.shrink(),
              value: _selectedWallet,
              hint: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8E8E8),
                    child: Icon(Icons.account_balance_wallet, size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text('total'.tr, style: AppTextStyles.body),
                ],
              ),
              items: walletItems.map((wallet) {
                return DropdownMenuItem<Wallet>(
                  value: wallet,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE8E8E8),
                        child: wallet == null
                            ? const Icon(Icons.account_balance_wallet, size: 20, color: Colors.black)
                            : Image.asset(wallet.iconPath, width: 24, height: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(wallet?.name ?? 'total'.tr, style: AppTextStyles.body),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedWallet = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr, style: AppTextStyles.button.copyWith(color: Colors.red))),
                    TextButton(onPressed: () => Get.back(), child: Text('done'.tr, style: AppTextStyles.button.copyWith(color: Colors.green))),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        int tempYear = _selectedDate.year;
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr, style: AppTextStyles.button.copyWith(color: Colors.red))),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(tempYear);
                        });
                        Get.back();
                      },
                      child: Text('ok'.tr, style: AppTextStyles.button.copyWith(color: Colors.green)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(initialItem: _selectedDate.year - 2018),
                  onSelectedItemChanged: (int index) {
                    tempYear = 2018 + index;
                  },
                  children: List<Widget>.generate(12, (int index) {
                    return Center(child: Text((2018 + index).toString(), style: AppTextStyles.body));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );
  }

  Widget _buildSummary() {
    final TransactionController transactionController = Get.find();
    final transactions = _getFilteredTransactions(transactionController.transactions);

    final double totalIncome = transactions.where((tx) => tx.type == TransactionType.income).fold(0, (sum, item) => sum + item.amount);
    final double totalExpense = transactions.where((tx) => tx.type == TransactionType.expense).fold(0, (sum, item) => sum + item.amount);
    final double total = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          _buildSummaryRow('expense'.tr, totalExpense, Colors.red),
          _buildSummaryRow('income'.tr, totalIncome, Colors.green),
          const Divider(),
          _buildSummaryRow('total'.tr, total, Colors.black, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color, {bool isTotal = false}) {
    final AppController appController = Get.find();
    String displayText;
    if (isTotal) {
      displayText = '${amount.toStringAsFixed(2)} ${appController.currencySymbol}';
    } else {
      final sign = title == 'income'.tr ? '+' : '-';
      displayText = '$sign${amount.toStringAsFixed(2)} ${appController.currencySymbol}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body.copyWith(color: Colors.grey[600])),
          Text(
            displayText,
            style: (isTotal ? AppTextStyles.title : AppTextStyles.subtitle).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(0, "total_expense".tr),
          _buildTabItem(1, "total_income".tr),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = _selectedChartTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedChartTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: isSelected ? Colors.green : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget _buildChartAndLegend() {
    final AppController appController = Get.find();
    final TransactionController transactionController = Get.find();
    final allTransactions = _getFilteredTransactions(transactionController.transactions);

    final TransactionType selectedType = _selectedChartTabIndex == 0 ? TransactionType.expense : TransactionType.income;

    final relevantTransactions = allTransactions.where((tx) => tx.type == selectedType).toList();
    final totalValue = relevantTransactions.fold(0.0, (sum, item) => sum + item.amount);

    final Map<String, double> categoryValue = {};
    for (var tx in relevantTransactions) {
      categoryValue.update(tx.categoryName, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    final List<PieChartSectionData> sections = categoryValue.entries.map((entry) {
      final category = defaultCategories.firstWhere(
        (cat) => cat.name == entry.key,
        orElse: () => Category(name: 'other'.tr, iconPath: '', colorValue: Colors.grey.value),
      );
      final percentage = totalValue > 0 ? (entry.value / totalValue) * 100 : 0.0;

      return PieChartSectionData(
        color: Color(category.colorValue),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (relevantTransactions.isNotEmpty)
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${('total'.tr)}\n${totalValue.toStringAsFixed(2)} ${appController.currencySymbol}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  PieChart(PieChartData(
                    sections: sections,
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                  )),
                ],
              ),
            ),
          ),
        if (relevantTransactions.isNotEmpty) const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: categoryValue.length,
              itemBuilder: (context, index) {
                final entry = categoryValue.entries.elementAt(index);
                final category = defaultCategories.firstWhere(
                  (cat) => cat.name == entry.key,
                  orElse: () => Category(name: 'other'.tr, iconPath: '', colorValue: Colors.grey.value),
                );
                return _buildLegendItem(Color(category.colorValue), entry.key.tr, entry.value);
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLegendItem(Color color, String name, double amount) {
    final AppController appController = Get.find();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                Text('${amount.toStringAsFixed(2)} ${appController.currencySymbol}', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    return transactions.where((tx) {
      final txDate = tx.date;
      bool dateMatch;
      if (_isMonthSelected) {
        dateMatch = txDate.year == _selectedDate.year && txDate.month == _selectedDate.month;
      } else {
        dateMatch = txDate.year == _selectedDate.year;
      }
      final walletMatch = _selectedWallet == null || tx.walletId == _selectedWallet!.id;
      return dateMatch && walletMatch;
    }).toList();
  }
}
