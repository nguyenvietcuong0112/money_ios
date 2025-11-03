import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'package:money_manager/screens/transaction_detail_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onScreenChanged;

  const HomeScreen({super.key, required this.onScreenChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('home'.tr, style: AppTextStyles.heading1),
        actions: [
          Obx(() {
            final walletController = Get.find<WalletController>();
            final appController = Get.find<AppController>();
            final totalBalance = walletController.totalBalance;
            return Row(
              children: [
                Text(
                  _isBalanceVisible ? '${appController.currencySymbol}${totalBalance.toStringAsFixed(2)}' : '*********',
                  style: AppTextStyles.title,
                ),
                IconButton(
                  icon: Icon(_isBalanceVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                  onPressed: () {
                    setState(() {
                      _isBalanceVisible = !_isBalanceVisible;
                    });
                  },
                ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMyWalletsSection(),
              const SizedBox(height: 30),
              _buildReportSection(),
              const SizedBox(height: 30),
              _buildRecentTransactionsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddTransactionScreen());
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyWalletsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('my_wallets'.tr, style: AppTextStyles.heading2),
            TextButton(
              onPressed: () { widget.onScreenChanged(2); },
              child: Text('see_all'.tr, style: AppTextStyles.subtitle.copyWith(color: Colors.green)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final walletController = Get.find<WalletController>();
          if (walletController.wallets.isEmpty) {
            return Text('no_wallets_available'.tr);
          }
          return SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: min(4, walletController.wallets.length),
              itemBuilder: (context, index) {
                final wallet = walletController.wallets[index];
                return _buildWalletCard(wallet);
              },
            ),
          );
        }),
      ],
    );
  }

  Color _getWalletColor(String walletName) {
    switch (walletName.toLowerCase()) {
      case 'credit':
        return Colors.blue;
      case 'e-wallet':
        return Colors.orange;
      case 'bank':
        return Colors.green;
      case 'cash':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildWalletCard(Wallet wallet) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getWalletColor(wallet.name).withOpacity(0.1),
            child: Image.asset(wallet.iconPath, width: 24, height: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(wallet.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                Obx(() {
                  final appController = Get.find<AppController>();
                  return Text(
                    _isBalanceVisible ? '${appController.currencySymbol}${wallet.balance.toStringAsFixed(2)}' : '***',
                    style: AppTextStyles.caption.copyWith(color: wallet.balance < 0 ? Colors.red : Colors.black87),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('report_this_month'.tr, style: AppTextStyles.heading2),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.withOpacity(0.1),
                ),
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: AppTextStyles.body,
                tabs: [
                  Tab(text: 'total_expense'.tr),
                  Tab(text: 'total_income'.tr),
                ],
                onTap: (index) {
                  setState(() {}); // Rebuild to update chart
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Obx(() {
                  final transactionController = Get.find<TransactionController>();
                  final appController = Get.find<AppController>();
                  final now = DateTime.now();
                  final monthTransactions = transactionController.transactions.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList();

                  final data = _prepareChartData(monthTransactions);

                  final chartData = _tabController.index == 0 ? data.$1 : data.$2;
                  final totalAmount = _tabController.index == 0 ? data.$3 : data.$4;

                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_tabController.index == 0 ? '-' : '+'}${appController.currencySymbol}${totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.totalAmount.copyWith(
                            color: _tabController.index == 0 ? AppTextStyles.expenseAmount.color : AppTextStyles.incomeAmount.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: _buildLineChart(chartData, _tabController.index == 0 ? Colors.red : Colors.green)),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (List<FlSpot>, List<FlSpot>, double, double) _prepareChartData(List<Transaction> transactions) {
    final expenseTransactions = transactions.where((tx) => tx.type == TransactionType.expense).toList();
    final totalExpense = expenseTransactions.fold(0.0, (sum, item) => sum + item.amount);
    final expenseDataByDay = groupBy(expenseTransactions, (Transaction tx) => tx.date.day);
    List<FlSpot> expenseSpots = [];
    for (var day = 1; day <= DateTime.now().day; day++) {
      final dayTotal = expenseDataByDay[day]?.fold(0.0, (sum, item) => sum + item.amount) ?? 0.0;
      expenseSpots.add(FlSpot(day.toDouble(), dayTotal));
    }
    if (expenseSpots.isEmpty) expenseSpots.add(const FlSpot(1, 0));

    final incomeTransactions = transactions.where((tx) => tx.type == TransactionType.income).toList();
    final totalIncome = incomeTransactions.fold(0.0, (sum, item) => sum + item.amount);
    final incomeDataByDay = groupBy(incomeTransactions, (Transaction tx) => tx.date.day);
    List<FlSpot> incomeSpots = [];
    for (var day = 1; day <= DateTime.now().day; day++) {
      final dayTotal = incomeDataByDay[day]?.fold(0.0, (sum, item) => sum + item.amount) ?? 0.0;
      incomeSpots.add(FlSpot(day.toDouble(), dayTotal));
    }
    if (incomeSpots.isEmpty) incomeSpots.add(const FlSpot(1, 0));

    return (expenseSpots, incomeSpots, totalExpense, totalIncome);
  }

  Widget _buildLineChart(List<FlSpot> spots, Color lineColor) {
    if (spots.isEmpty) {
      return Center(child: Text('no_data_for_this_month'.tr));
    }

    final double maxAmount = spots.map((spot) => spot.y).fold(0.0, (max, current) => max > current ? max : current);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                Widget text;
                switch (value.toInt()) {
                  case 1: text = const Text('1'); break;
                  case 5: text = const Text('5'); break;
                  case 10: text = const Text('10'); break;
                  case 15: text = const Text('15'); break;
                  case 20: text = const Text('20'); break;
                  case 25: text = const Text('25'); break;
                  case 30: text = const Text('30'); break;
                  default: text = const Text(''); break;
                }
                return SideTitleWidget(meta: meta, child: text);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: DateTime.now().day.toDouble(),
        minY: 0,
        maxY: maxAmount * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('recent_transactions'.tr, style: AppTextStyles.heading2),
            TextButton(
              onPressed: () { widget.onScreenChanged(1); },
              child: Text('see_all'.tr, style: AppTextStyles.subtitle.copyWith(color: Colors.green)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final transactionController = Get.find<TransactionController>();
          final recentTransactions = transactionController.transactions.take(5).toList();
          if (recentTransactions.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('no_recent_transactions'.tr)));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = recentTransactions[index];
              return _buildTransactionItem(transaction);
            },
          );
        }),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Color(transaction.colorValue).withAlpha(25),
          child: Image.asset(transaction.iconPath, width: 28, height: 28, color: Color(transaction.colorValue)),
        ),
        title: Text(transaction.categoryName.tr, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)), // Dịch
        subtitle: Text(transaction.title.isNotEmpty ? transaction.title : DateFormat('d MMMM yyyy').format(transaction.date), style: AppTextStyles.caption),
        trailing: Obx(() {
          final appController = Get.find<AppController>();
          return Text(
            '${transaction.type == TransactionType.income ? '+' : '-'}${appController.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
            style: transaction.type == TransactionType.income
                ? AppTextStyles.incomeAmount
                : AppTextStyles.expenseAmount,
          );
        }),
        onTap: () {
          Get.to(() => TransactionDetailScreen(transaction: transaction));
        },
      ),
    );
  }
}
