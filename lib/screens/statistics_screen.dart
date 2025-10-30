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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistic'),
      ),
      body: Column(
        children: [
          // _buildTotalCard(transactionProvider),
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

  Widget _buildChartView(BuildContext context, {required bool isExpense}) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final selectedDate = DateFormat('MMM yyyy').parse(_selectedMonth);
    final transactions = transactionProvider.transactions
        .where((t) =>
            (isExpense
                ? t.type == TransactionType.expense
                : t.type == TransactionType.income) &&
            t.date.year == selectedDate.year &&
            t.date.month == selectedDate.month)
        .toList();

    final Map<String, double> dataByCategory = {};
    for (var transaction in transactions) {
      dataByCategory.update(
        transaction.title, // Using title as category for now
        (value) => value + transaction.amount.abs(),
        ifAbsent: () => transaction.amount.abs(),
      );
    }

    if (dataByCategory.isEmpty) {
      return const Center(child: Text('No data for this month.'));
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
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
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
                        return Padding(
                            padding: const EdgeInsets.only(top: 8.0), child: text);
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
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
                          borderRadius: BorderRadius.circular(4))
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
              // final icon = _getIconForCategory(entry.key);
              return ListTile(
                // leading: Icon(icon, color: colors[index % colors.length]),
                title: Text(entry.key),
                trailing: Text(
                  '${isExpense ? '-' : '+'}\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: isExpense
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontWeight: FontWeight.w500),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
