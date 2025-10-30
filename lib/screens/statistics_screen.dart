
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/providers/budget_provider.dart';
import 'package:money_manager/utils/constants.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedMonth;
  final List<String> _months = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateMonths();
    _selectedMonth = _months.first;
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _generateMonths() {
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      _months.add(DateFormat('MMM yyyy').format(date));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _getIconForCategory(String categoryName) {
    final category = categories.firstWhere(
      (c) => c['name'] == categoryName,
      orElse: () => {'icon': 0xe88f}, // Default icon (help_outline)
    );
    return IconData(category['icon'] as int, fontFamily: 'MaterialIcons');
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistic'),
      ),
      body: Column(
        children: [
          _buildTotalCard(budgetProvider),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
              Tab(text: 'Loan'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: _selectedMonth,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue!;
                    });
                  },
                  items: _months.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpenseView(budgetProvider),
                _buildIncomeView(budgetProvider),
                _buildLoanView(budgetProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BudgetProvider budgetProvider) {
    final selectedDate = DateFormat('MMM yyyy').parse(_selectedMonth);
    List<Transaction> filteredTransactions;

    if (_tabController.index == 0) { // Expense
      filteredTransactions = budgetProvider.transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.year == selectedDate.year &&
              t.date.month == selectedDate.month)
          .toList();
    } else if (_tabController.index == 1) { // Income
      filteredTransactions = budgetProvider.transactions
          .where((t) =>
              t.type == 'income' &&
              t.date.year == selectedDate.year &&
              t.date.month == selectedDate.month)
          .toList();
    } else { // Loan
      filteredTransactions = [];
    }

    final total = filteredTransactions.fold<double>(0, (prev, t) => prev + t.amount);

    return Card(
      color: Colors.blue.shade700,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
                Text('\$${total.abs().toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseView(BudgetProvider budgetProvider) {
    final selectedDate = DateFormat('MMM yyyy').parse(_selectedMonth);
    final expenses = budgetProvider.transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == selectedDate.year &&
            t.date.month == selectedDate.month)
        .toList();

    final Map<String, double> expenseByCategory = {};
    for (var transaction in expenses) {
      expenseByCategory.update(
        transaction.category,
        (value) => value + transaction.amount.abs(),
        ifAbsent: () => transaction.amount.abs(),
      );
    }

    return _buildChartAndList(expenseByCategory, true);
  }

  Widget _buildIncomeView(BudgetProvider budgetProvider) {
    final selectedDate = DateFormat('MMM yyyy').parse(_selectedMonth);
    final incomes = budgetProvider.transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.year == selectedDate.year &&
            t.date.month == selectedDate.month)
        .toList();

    final Map<String, double> incomeByCategory = {};
    for (var transaction in incomes) {
      incomeByCategory.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return _buildChartAndList(incomeByCategory, false);
  }

  Widget _buildLoanView(BudgetProvider budgetProvider) {
    return const Center(child: Text('Loan data not available yet'));
  }

  Widget _buildChartAndList(Map<String, double> data, bool isExpense) {
    if (data.isEmpty) {
      return const Center(child: Text('No data for this month.'));
    }

    final chartData = data.entries.toList();
    final colors = isExpense 
      ? [Colors.orange.shade400, Colors.pink.shade300, Colors.teal.shade300, Colors.lightBlue.shade300, Colors.purple.shade300] 
      : [Colors.green.shade400, Colors.blue.shade400, Colors.teal.shade400, Colors.indigo.shade300, Colors.amber.shade400];

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData:  BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontSize: 10,
                        );
                        Widget text;
                        if (value.toInt() < chartData.length) {
                          text = Text(chartData[value.toInt()].key, style: style);
                        } else {
                          text = const Text('', style: style);
                        }
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: text);
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(chartData.length, (index) {
                  final entry = chartData[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: colors[index % colors.length],
                        width: 16,
                        borderRadius: BorderRadius.circular(4)
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: chartData.length,
            itemBuilder: (context, index) {
              final entry = chartData[index];
              return ListTile(
                leading: Icon(_getIconForCategory(entry.key), color: colors[index % colors.length]),
                title: Text(entry.key),
                trailing: Text(
                  '${isExpense ? '-' : '+'}\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(color: isExpense ? Colors.red.shade700 : Colors.green.shade700, fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
