import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  final Function(int) onScreenChanged;

  const StatisticsScreen({super.key, required this.onScreenChanged});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isExpense = true;

  // Using the same hardcoded categories as AddTransactionScreen for consistency
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

  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Set a default category if the list is not empty
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(localizations?.translate('statistics') ?? 'Statistics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildToggleButtons(localizations),
              const SizedBox(height: 24.0),
              _buildChart(context),
              const SizedBox(height: 24.0),
              _buildCategoryDropdown(localizations),
              const SizedBox(height: 16.0),
              _buildCategorySpendingList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons(AppLocalizations? localizations) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isExpense = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isExpense ? Colors.red : Colors.grey[300],
              foregroundColor: _isExpense ? Colors.white : Colors.black,
            ),
            child: Text(localizations?.translate('expense') ?? 'Expense'),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isExpense = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isExpense ? Colors.green : Colors.grey[300],
              foregroundColor: !_isExpense ? Colors.white : Colors.black,
            ),
            child: Text(localizations?.translate('income') ?? 'Income'),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions
        .where((tx) => _isExpense ? tx.type == TransactionType.expense : tx.type == TransactionType.income)
        .toList();

    final totalAmount = transactions.fold(0.0, (sum, item) => sum + item.amount);

    // Group transactions by category
    final Map<String, double> categorySpending = {};
    for (var tx in transactions) {
      categorySpending.update(tx.title, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    // Find the corresponding category object to get color
    final List<PieChartSectionData> sections = categorySpending.entries.map((entry) {
      final category = _categories.firstWhere(
        (cat) => cat.name == entry.key,
        orElse: () => Category(name: 'Other', iconPath: 'assets/icons/ic_food.png', colorValue: Colors.grey.value),
      );
      final percentage = (entry.value / totalAmount) * 100;
      return PieChartSectionData(
        color: Color(category.colorValue),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: transactions.isEmpty
          ? const Center(child: Text('No data available'))
          : PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations? localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          isExpanded: true,
          value: _selectedCategory,
          hint: Text(localizations?.translate('select_category') ?? 'Select Category'),
          onChanged: (Category? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          items: _categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Row(
                children: [
                  Image.asset(category.iconPath, width: 24, height: 24, color: Color(category.colorValue)),
                  const SizedBox(width: 10),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategorySpendingList(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    if (_selectedCategory == null) {
      return const SizedBox.shrink();
    }

    final categoryTransactions = transactionProvider.transactions
        .where((tx) =>
            tx.title == _selectedCategory!.name &&
            (_isExpense ? tx.type == TransactionType.expense : tx.type == TransactionType.income))
        .toList();

    final double totalCategorySpending = categoryTransactions.fold(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total for ${_selectedCategory!.name}: \$${totalCategorySpending.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryTransactions.length,
          itemBuilder: (context, index) {
            final transaction = categoryTransactions[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(transaction.colorValue),
                child: Image.asset(transaction.iconPath, width: 24, height: 24),
              ),
              title: Text(transaction.title),
              trailing: Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ],
    );
  }
}
