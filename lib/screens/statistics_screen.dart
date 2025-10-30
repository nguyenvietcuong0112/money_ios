import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedMonth;
  final List<String> _months = [];
  double _spendingLimit = 1000.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMonths();
    _selectedMonth = _months.first;
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _generateMonths() {
    _months.add('All Time');
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

  void _setSpendingLimit() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _spendingLimit.toString());
        return AlertDialog(
          title: const Text('Set Spending Limit'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Limit',
              suffixText: '\$',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _spendingLimit = double.tryParse(controller.text) ?? _spendingLimit;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistic'),
      ),
      body: Column(
        children: [
          _buildSpendingLimitCard(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
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
                _buildChartView(context, isExpense: true),
                _buildChartView(context, isExpense: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingLimitCard() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final totalExpense = transactionProvider.totalExpense;
    final percentage = totalExpense / _spendingLimit;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Spending Limit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _setSpendingLimit,
                  child: const Text('Set Limit'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percentage.isNaN || percentage.isInfinite ? 0 : percentage,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 1 ? Colors.red : (percentage > 0.8 ? Colors.orange : Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            Text('\$${totalExpense.toStringAsFixed(2)} / \$${_spendingLimit.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildChartView(BuildContext context, {required bool isExpense}) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final List<Transaction> transactions;

    if (_selectedMonth == 'All Time') {
      transactions = transactionProvider.transactions
          .where((t) => isExpense ? t.type == TransactionType.expense : t.type == TransactionType.income)
          .toList();
    } else {
      final selectedDate = DateFormat('MMM yyyy').parse(_selectedMonth);
      transactions = transactionProvider.transactions
          .where((t) =>
              (isExpense ? t.type == TransactionType.expense : t.type == TransactionType.income) &&
              t.date.year == selectedDate.year &&
              t.date.month == selectedDate.month)
          .toList();
    }

    final Map<String, double> dataByCategory = {};
    final Map<String, IconData> iconsByCategory = {};
    for (var transaction in transactions) {
      dataByCategory.update(
        transaction.title, // Using title as category for now
        (value) => value + transaction.amount.abs(),
        ifAbsent: () => transaction.amount.abs(),
      );
      iconsByCategory.putIfAbsent(transaction.title, () => transaction.icon);
    }

    if (dataByCategory.isEmpty) {
      return const Center(child: Text('No data for this period.'));
    }

    final chartData = dataByCategory.entries.toList();
    final colors = isExpense
        ? [
            Colors.orange.shade400,
            Colors.pink.shade300,
            Colors.teal.shade300,
            Colors.lightBlue.shade300,
            Colors.purple.shade300
          ]
        : [
            Colors.green.shade400,
            Colors.blue.shade400,
            Colors.teal.shade400,
            Colors.indigo.shade300,
            Colors.amber.shade400
          ];

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: PieChart(
                PieChartData(
                  sections: List.generate(chartData.length, (index) {
                    final entry = chartData[index];
                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: entry.value,
                      title: '${(entry.value / transactionProvider.totalExpense * 100).toStringAsFixed(0)}%',
                      radius: 80,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: chartData.length,
            itemBuilder: (context, index) {
              final entry = chartData[index];
              final icon = iconsByCategory[entry.key];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ListTile(
                  leading: Icon(icon, color: colors[index % colors.length]),
                  title: Text(entry.key),
                  trailing: Text(
                    '${isExpense ? '-' : '+'}\$${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: isExpense
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
