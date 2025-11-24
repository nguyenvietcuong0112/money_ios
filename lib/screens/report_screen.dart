
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/models/category_data.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class ReportScreen extends StatefulWidget {
  final Function(int) onScreenChanged;

  const ReportScreen({super.key, required this.onScreenChanged});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'EXPENSE';
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7), // Fixed color
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F7), // Fixed color
        elevation: 0,
        title: Text('report'.tr,
            style: AppTextStyles.title.copyWith(color: Colors.black)), // Fixed color
        actions: [
          _buildDateFilter(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final TransactionController transactionController = Get.find();
          final transactions =
              _getFilteredTransactions(transactionController.transactions);

          final double totalIncome = transactions
              .where((tx) => tx.type == TransactionType.income)
              .fold(0, (sum, item) => sum + item.amount);
          final double totalExpense = transactions
              .where((tx) => tx.type == TransactionType.expense)
              .fold(0, (sum, item) => sum + item.amount);
          final double saving = totalIncome - totalExpense;

          final expenseTransactions = transactions
              .where((tx) => tx.type == TransactionType.expense)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(
                  totalExpense, totalIncome, saving, appController.currencySymbol),
              const SizedBox(height: 24.0),
              _buildExpenseTypeDropdown(),
              const SizedBox(height: 16.0),
              if (expenseTransactions.isNotEmpty)
                _buildChart(expenseTransactions)
              else
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('no_data_available'.tr, style: AppTextStyles.body),
                  ),
                ),
              const SizedBox(height: 24.0),
              _buildExpenseList(expenseTransactions),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDateFilter() {
    return GestureDetector(
      onTap: () {
        showMonthPicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2018),
          lastDate: DateTime.now(),
        ).then((date) {
          if (date != null) {
            setState(() {
              _selectedDate = date;
            });
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3A8D), // Fixed color
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalExpense, double totalIncome,
      double saving, String currencySymbol) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('assets/icons/ic_expense.svg', 'Total EXPENSE',
                  totalExpense, Colors.red, currencySymbol),
              _buildSummaryItem('assets/icons/ic_income.svg', 'Total INCOME',
                  totalIncome, Colors.green, currencySymbol),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildSavingItem(
              'assets/icons/ic_saving.svg', 'SAVING', saving, const Color(0xFF8A5AC5), currencySymbol),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String icon, String title, double amount,
      Color amountColor, String currencySymbol) {
    return Row(
          children: [
            SvgPicture.asset(icon, width: 40, height: 40),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption.copyWith(color: amountColor, fontWeight: FontWeight.bold)),
                Text(
                  '${amount.toStringAsFixed(0)}$currencySymbol',
                  style: AppTextStyles.title.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        );
  }

    Widget _buildSavingItem(String icon, String title, double amount,
      Color iconColor, String currencySymbol) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(icon, width: 40, height: 40, color: iconColor),
        const SizedBox(width: 16),
        Text('$title: ', style: AppTextStyles.subtitle.copyWith(color: iconColor, fontWeight: FontWeight.bold)),
        Text(
          '${amount.toStringAsFixed(0)}$currencySymbol',
          style: AppTextStyles.title.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildExpenseTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedType,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: ['EXPENSE', 'INCOME'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value.tr, style: AppTextStyles.body),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedType = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildChart(List<Transaction> transactions) {
    final Map<String, double> categoryValue = {};
    for (var tx in transactions) {
      categoryValue.update(tx.categoryName, (value) => value + tx.amount,
          ifAbsent: () => tx.amount);
    }
    final totalValue = transactions.fold(0.0, (sum, item) => sum + item.amount);


    final List<PieChartSectionData> sections =
        categoryValue.entries.map((entry) {
      final category = defaultCategories.firstWhere(
        (cat) => cat.name == entry.key,
        orElse: () =>
            Category(name: 'other'.tr, iconPath: '', colorValue: Colors.grey.value),
      );

      final isTouched =
          categoryValue.entries.toList().indexOf(entry) == touchedIndex;
      final radius = isTouched ? 80.0 : 70.0;
      final percentage = totalValue > 0 ? (entry.value / totalValue) * 100 : 0.0;


      return PieChartSectionData(
        color: Color(category.colorValue),
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 70,
          sections: sections,
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<Transaction> transactions) {
    Map<String, double> categoryTotals = {};
    for (var tx in transactions) {
      categoryTotals.update(tx.categoryName, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    var sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));


    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final categoryEntry = sortedCategories[index];
        final category = defaultCategories.firstWhere(
          (cat) => cat.name == categoryEntry.key,
          orElse: () => Category(name: 'other'.tr, iconPath: '', colorValue: Colors.grey.value),
        );

        // Find a transaction for this category to display the date. This is not ideal.
        final transactionForDate = transactions.firstWhere((tx) => tx.categoryName == category.name, orElse: () => transactions.first);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(category.colorValue).withOpacity(0.1),
              child: SvgPicture.asset(category.iconPath, width: 24, height: 24),
            ),
            title: Text(category.name.tr, style: AppTextStyles.subtitle),
            subtitle: Text(
              DateFormat('d MMMM yyyy').format(transactionForDate.date), 
              style: AppTextStyles.caption.copyWith(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${categoryEntry.value.toStringAsFixed(0)}\$',
                  style: AppTextStyles.subtitle.copyWith(color: Colors.red),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    return transactions.where((tx) {
      final txDate = tx.date;
      bool dateMatch = txDate.year == _selectedDate.year && txDate.month == _selectedDate.month;
      return dateMatch;
    }).toList();
  }
}
