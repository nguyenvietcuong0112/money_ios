import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
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
  String _selectedYear = DateFormat('yyyy').format(DateTime.now());
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  Wallet? _selectedWallet;

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

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
        child: Column(
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
            _buildChartAndLegend(),
            const SizedBox(height: 24.0),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final WalletController walletController = Get.find();

    return Row(
      children: [
        Expanded(
          child: _buildDropdownContainer(
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox.shrink(),
              value: _selectedYear,
              items: ['2023', '2024', '2025'].map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedYear = value);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        if (_isMonthSelected)
          Expanded(
            child: _buildDropdownContainer(
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox.shrink(),
                value: _selectedMonth,
                items: _months.map((month) => DropdownMenuItem(value: month, child: Text(month))).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMonth = value);
                  }
                },
              ),
            ),
          )
        else
          Expanded(
            child: _buildDropdownContainer(
              child: DropdownButton<Wallet>(
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: const Text('Total'),
                value: _selectedWallet,
                items: walletController.wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet,
                    child: Row(
                      children: [
                        Image.asset(wallet.iconPath, width: 24, height: 24),
                        const SizedBox(width: 8),
                        Text(wallet.name),
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

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
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

    final double totalIncome = transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
    final double totalExpense = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
    final double total = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Expense', totalExpense, Colors.red),
          _buildSummaryRow('Income', totalIncome, Colors.green),
          const Divider(),
          _buildSummaryRow('Total', total, total >= 0 ? Colors.green : Colors.red, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color, {bool isTotal = false}) {
    final format = NumberFormat.simpleCurrency(locale: 'en_GB');
    final formattedAmount = (amount >= 0 ? '+' : '-') + format.format(amount.abs());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: isTotal ? 20 : 18,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartAndLegend() {
    final TransactionController transactionController = Get.find();
    final expenseTransactions = _getFilteredTransactions(transactionController.transactions)
        .where((tx) => tx.type == TransactionType.expense)
        .toList();

    final totalExpense = expenseTransactions.fold(0.0, (sum, item) => sum + item.amount);

    final Map<String, double> categorySpending = {};
    for (var tx in expenseTransactions) {
      categorySpending.update(tx.title, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    final List<PieChartSectionData> sections = categorySpending.entries.map((entry) {
      final category = _categories.firstWhere(
        (cat) => cat.name == entry.key,
        orElse: () => Category(name: 'Other', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.grey.value),
      );
      return PieChartSectionData(
        color: Color(category.colorValue),
        value: entry.value,
        title: '',
        radius: 40,
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Total Expense\n${NumberFormat.simpleCurrency(locale: 'en_GB').format(totalExpense)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                PieChart(PieChartData(sections: sections, centerSpaceRadius: 60)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ListView.builder(
              itemCount: categorySpending.length,
              itemBuilder: (context, index) {
                final entry = categorySpending.entries.elementAt(index);
                 final category = _categories.firstWhere(
                  (cat) => cat.name == entry.key,
                  orElse: () => Category(name: 'Other', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.grey.value),
                );
                return _buildLegendItem(Color(category.colorValue), entry.key);
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLegendItem(Color color, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final TransactionController transactionController = Get.find();
    final transactions = _getFilteredTransactions(transactionController.transactions);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionItem(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final category = _categories.firstWhere(
      (cat) => cat.name == transaction.title,
      orElse: () => Category(name: 'Other', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.grey.value),
    );

    final color = Color(transaction.colorValue);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(50),
        child: Image.asset(transaction.iconPath, width: 24, height: 24, color: color),
      ),
      title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
      trailing: Text(
        (transaction.type == TransactionType.income ? '+' : '-') + 
        NumberFormat.simpleCurrency(locale: 'en_GB').format(transaction.amount),
        style: TextStyle(
          color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    return transactions.where((tx) {
      final txDate = tx.date;
      final monthAsNumber = _months.indexOf(_selectedMonth) + 1;

      bool yearMatch = txDate.year.toString() == _selectedYear;
      bool walletMatch = _selectedWallet == null || tx.walletId == _selectedWallet!.id;
      bool monthMatch = txDate.month == monthAsNumber;

      if (_isMonthSelected) {
        return yearMatch && monthMatch && walletMatch;
      }
      return yearMatch && walletMatch;
    }).toList();
  }
}
