import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          _buildHeader(),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: OvalClipper(),
      child: Container(
        height: 250,
        color: const Color(0xFF4A80F0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Total balance', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Obx(() {
                  final walletController = Get.find<WalletController>();
                  final appController = Get.find<AppController>();
                  final totalBalance = walletController.totalBalance;
                  return Row(
                    children: [
                      Text(
                        _isBalanceVisible
                            ? '${appController.currencySymbol}${totalBalance.toStringAsFixed(2)}'
                            : '*********',
                        style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 36),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 200), // Start content below the curved header
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
    );
  }

    Widget _buildMyWalletsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My wallet', style: AppTextStyles.heading2),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final walletController = Get.find<WalletController>();
          if (walletController.wallets.isEmpty) {
            return Text('no_wallets_available'.tr);
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: walletController.wallets
                .take(3)
                .map((wallet) => Expanded(child: _buildWalletCard(wallet)))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildWalletCard(Wallet wallet) {
     final AppController appController = Get.find();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
      child: Column(
        children: [
          SvgPicture.asset(wallet.iconPath, width: 40, height: 40),
          const SizedBox(height: 8),
          Text(wallet.name, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
             _isBalanceVisible ? '${appController.currencySymbol}${wallet.balance.toStringAsFixed(0)}' : '***',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report this month', style: AppTextStyles.heading2),
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
             Obx(() {
                final transactionController = Get.find<TransactionController>();
                  final appController = Get.find<AppController>();
                  final now = DateTime.now();
                  final monthTransactions = transactionController.transactions.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList();

                  final data = _prepareChartData(monthTransactions);
                  final totalExpense = data.$3;
                  final totalIncome = data.$4;
              return Row(
                children: [
                  Expanded(child: _buildReportCard('Total EXPENSE', totalExpense, false)),
                  Expanded(child: _buildReportCard('Total INCOME', totalIncome, true)),
                ],
              );
             }),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Obx(() {
                  final transactionController = Get.find<TransactionController>();
                  final now = DateTime.now();
                  final monthTransactions = transactionController.transactions.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList();

                  final data = _prepareChartData(monthTransactions);
                  final chartData = data.$1; // Show expense data by default

                  return _buildLineChart(chartData, Colors.red); // Chart for expense
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, double amount, bool isIncome) {
    final AppController appController = Get.find();
    return Container(
       padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIncome ? const Color(0xFF50B432) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome? Colors.white : Colors.red),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(color: isIncome ? Colors.white : Colors.black87)),
              Text(
                '${appController.currencySymbol}${amount.toStringAsFixed(0)}',
                 style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: isIncome ? Colors.white : Colors.black),
              )
            ],
          )
        ],
      ),
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
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles:false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                Widget text;
                switch (value.toInt()) {
                  case 1: text = Text('1', style: AppTextStyles.caption); break;
                  case 5: text = Text('5', style: AppTextStyles.caption); break;
                  case 10: text = Text('10', style: AppTextStyles.caption); break;
                  case 15: text = Text('15', style: AppTextStyles.caption); break;
                  case 20: text = Text('20', style: AppTextStyles.caption); break;
                  case 25: text = Text('25', style: AppTextStyles.caption); break;
                  case 30: text = Text('30', style: AppTextStyles.caption); break;
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
        maxY: maxAmount > 0 ? maxAmount * 1.2 : 100, // Avoid maxY being 0
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report this month', style: AppTextStyles.heading2), // As per image
        const SizedBox(height: 10),
        Obx(() {
          final transactionController = Get.find<TransactionController>();
          final recentTransactions = transactionController.transactions;
          if (recentTransactions.isEmpty) {
            return _buildEmptyTransactionState();
          }
          return _buildTransactionList(recentTransactions);
        }),
      ],
    );
  }

   Widget _buildEmptyTransactionState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SvgPicture.asset('assets/icons/ic_add_file.svg', width: 60, height: 60),
              const SizedBox(height: 16),
              Text('add_your_first_transaction'.tr, style: AppTextStyles.body.copyWith(color: Colors.grey)),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => Get.to(() => const AddTransactionScreen()),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFE645E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: min(5, transactions.length), // Show at most 5
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
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
          child: SvgPicture.asset(transaction.iconPath, width: 28, height: 28),
        ),
        title: Text(transaction.categoryName.tr, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
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


class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
