
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_manager/providers/app_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final transactions = appProvider.transactions;

    // Calculate expense by category
    final Map<String, double> expenseByCategory = {};
    for (var transaction in transactions) {
      if (transaction.isExpense) {
        expenseByCategory.update(
          transaction.category,
          (value) => value + transaction.amount.abs(),
          ifAbsent: () => transaction.amount.abs(),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: expenseByCategory.isEmpty
          ? const Center(child: Text('No expenses to show in chart.'))
          : Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: expenseByCategory.entries.map((entry) {
                        return PieChartSectionData(
                          color: Colors.primaries[expenseByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                          value: entry.value,
                          title: '${(entry.value / expenseByCategory.values.reduce((a, b) => a + b) * 100).toStringAsFixed(0)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffffffff),
                          ),
                        );
                      }).toList(),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: expenseByCategory.keys.map((category) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: Colors.primaries[expenseByCategory.keys.toList().indexOf(category) % Colors.primaries.length],
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
