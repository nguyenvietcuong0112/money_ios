import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_manager/models/transaction_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<TransactionModel> transactionBox = Hive.box<TransactionModel>('transactions');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ValueListenableBuilder(
        valueListenable: transactionBox.listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }

          // Calculate expense by category
          final Map<String, double> expenseByCategory = {};
          for (var transaction in box.values) {
            if (transaction.amount < 0) { // Only consider expenses
              expenseByCategory.update(
                transaction.category,
                (value) => value + transaction.amount.abs(),
                ifAbsent: () => transaction.amount.abs(),
              );
            }
          }

          if (expenseByCategory.isEmpty) {
            return const Center(child: Text('No expenses to show in chart.'));
          }

          // Create pie chart data
          final List<PieChartSectionData> pieChartSections = expenseByCategory.entries.map((entry) {
            final isTouched = false; // Placeholder for interactivity
            final fontSize = isTouched ? 25.0 : 16.0;
            final radius = isTouched ? 60.0 : 50.0;
            return PieChartSectionData(
              color: Colors.primaries[expenseByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
              value: entry.value,
              title: '${(entry.value / expenseByCategory.values.reduce((a, b) => a + b) * 100).toStringAsFixed(0)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff),
              ),
            );
          }).toList();

          return Column(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: pieChartSections,
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
          );
        },
      ),
    );
  }
}
