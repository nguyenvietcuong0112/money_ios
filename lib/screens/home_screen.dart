import 'dart:math';
import 'package:collection/collection.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/color.dart';
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
  bool _isIncomeSelected = false;
  DateTime _selectedMonth = DateTime.now();
  TransactionType _selectedType = TransactionType.expense; // mặc định expense

  String _formatBalance(double balance) {
    if (balance >= 1000000000) {
      return '${(balance / 1000000000).toStringAsFixed(1)}B';
    } else if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(1)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(1)}K';
    }
    return balance.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_appbar_home.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Flexible(
              child: Text(
                'total_balance'.tr,
                style: AppTextStyles.heading2White,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final walletController = Get.find<WalletController>();
            final appController = Get.find<AppController>();
            final totalBalance = walletController.totalBalance;

            return Flexible( // Thêm Flexible để cho phép co giãn
              child: Row(
                mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
                children: [
                  Flexible( // Wrap Text với Flexible
                    child: Text(
                      _isBalanceVisible
                          ? '${appController.currencySymbol}${_formatBalance(totalBalance)}'
                          : '*********',
                      style: AppTextStyles.heading1White,
                      maxLines: 1, // Giới hạn 1 dòng
                      overflow: TextOverflow.ellipsis, // Hiển thị ... khi tràn
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        _isBalanceVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    padding: EdgeInsets.zero, // Giảm padding
                    constraints: const BoxConstraints(), // Giảm kích thước tối thiểu
                  ),
                ],
              ),
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
      floatingActionButton: DraggableFab(
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => const AddTransactionScreen());
          },
          shape: CircleBorder(),
          backgroundColor: AppColors.textColorRed,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
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
            Text('my_wallets'.tr,
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textDefault)),
            // TextButton(
            //   onPressed: () { widget.onScreenChanged(2); },
            //   child: Text('see_all'.tr, style: AppTextStyles.subtitle.copyWith(color: Colors.green)),
            // ),
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
        borderRadius: BorderRadius.circular(16),
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
            child: SvgPicture.asset(wallet.iconPath, width: 50, height: 50),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min, // chỉ chiếm height cần thiết
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Obx(() {
                  final appController = Get.find<AppController>();
                  return Text(
                    '${wallet.balance.toStringAsFixed(0)}${appController.currencySymbol}',
                    style: AppTextStyles.caption.copyWith(
                        color: wallet.balance < 0
                            ? AppColors.textColorRed
                            : AppColors.textColorGreen),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
          )

        ],
      ),
    );
  }

  void _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('report_this_month'.tr,
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textDefault)),
            // GestureDetector(
            //   onTap: () => _selectMonth(context),
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //     decoration: BoxDecoration(
            //       color: Colors.green.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         const Icon(Icons.calendar_today,
            //             size: 16, color: Colors.green),
            //         const SizedBox(width: 6),
            //         Text(
            //           DateFormat('MM/yyyy').format(_selectedMonth),
            //           style: AppTextStyles.caption.copyWith(
            //             color: Colors.green,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
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
                final monthTransactions = transactionController.transactions
                    .where((tx) =>
                        tx.date.year == _selectedMonth.year &&
                        tx.date.month == _selectedMonth.month)
                    .toList();

                final data = _prepareChartData(monthTransactions);
                final totalExpense = data.$3;
                final totalIncome = data.$4;
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncomeSelected = false),
                        child: _buildReportCard('total_expense'.tr,
                            totalExpense, !_isIncomeSelected),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncomeSelected = true),
                        child: _buildReportCard(
                            'total_income'.tr, totalIncome, _isIncomeSelected),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 200,
                  child: Obx(() {
                    final transactionController =
                        Get.find<TransactionController>();
                    final monthTransactions = transactionController.transactions
                        .where((tx) =>
                            tx.date.year == _selectedMonth.year &&
                            tx.date.month == _selectedMonth.month)
                        .toList();

                    final data = _prepareChartData(monthTransactions);
                    final chartData = _isIncomeSelected ? data.$2 : data.$1;
                    final chartColor =
                        _isIncomeSelected ? Colors.green : Colors.red;

                    if (chartData.isEmpty ||
                        chartData.every((spot) => spot.y == 0)) {
                      return Center(
                        child: Text(
                          'no_data_for_this_month'.tr,
                          style:
                              AppTextStyles.body.copyWith(color: Colors.grey),
                        ),
                      );
                    }

                    return _buildLineChart(chartData, chartColor);
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, double amount, bool isSelected) {
    final AppController appController = Get.find();
    final bool isIncome = title == 'total_income'.tr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? (isIncome ? AppColors.textColorGreen : AppColors.textColorRed)
            : Colors.transparent,
        borderRadius: BorderRadius.only(
            topLeft:
                isIncome ? const Radius.circular(0) : const Radius.circular(16),
            topRight: isIncome
                ? const Radius.circular(16)
                : const Radius.circular(0)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            isIncome
                ? 'assets/icons/ic_income.svg'
                : 'assets/icons/ic_expense.svg',
            width: 45,
            height: 45,
            color: isSelected
                ? AppColors.textColorWhite
                : AppColors.textColorGrey,
          ),
          const SizedBox(width: 8),
          Expanded( // <- cho Column chiếm không gian còn lại, tránh tràn
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // chỉ chiếm height cần thiết
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? AppColors.textColorWhite
                        : AppColors.textColorGrey,
                  ),
                ),
                Text(
                  '${appController.currencySymbol}${amount.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.textColorWhite
                        : AppColors.textColorGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      )

    );
  }

  (List<FlSpot>, List<FlSpot>, double, double, int, int) _prepareChartData(
      List<Transaction> transactions) {
    // Tìm ngày đầu tiên và cuối cùng có data
    int minDay = 1;
    int maxDay = 1;

    if (transactions.isNotEmpty) {
      final days = transactions.map((tx) => tx.date.day).toList();
      minDay = days.reduce(min);
      maxDay = days.reduce(max);
    }

    // Expense data
    final expenseTransactions =
        transactions.where((tx) => tx.type == TransactionType.expense).toList();
    final totalExpense =
        expenseTransactions.fold(0.0, (sum, item) => sum + item.amount);
    final expenseDataByDay =
        groupBy(expenseTransactions, (Transaction tx) => tx.date.day);
    List<FlSpot> expenseSpots = [];

    if (expenseTransactions.isNotEmpty) {
      for (var day = minDay; day <= maxDay; day++) {
        final dayTotal = expenseDataByDay[day]
                ?.fold(0.0, (sum, item) => sum + item.amount) ??
            0.0;
        expenseSpots.add(FlSpot(day.toDouble(), dayTotal));
      }
    } else {
      expenseSpots.add(const FlSpot(1, 0));
    }

    // Income data
    final incomeTransactions =
        transactions.where((tx) => tx.type == TransactionType.income).toList();
    final totalIncome =
        incomeTransactions.fold(0.0, (sum, item) => sum + item.amount);
    final incomeDataByDay =
        groupBy(incomeTransactions, (Transaction tx) => tx.date.day);
    List<FlSpot> incomeSpots = [];

    if (incomeTransactions.isNotEmpty) {
      for (var day = minDay; day <= maxDay; day++) {
        final dayTotal =
            incomeDataByDay[day]?.fold(0.0, (sum, item) => sum + item.amount) ??
                0.0;
        incomeSpots.add(FlSpot(day.toDouble(), dayTotal));
      }
    } else {
      incomeSpots.add(const FlSpot(1, 0));
    }

    return (
      expenseSpots,
      incomeSpots,
      totalExpense,
      totalIncome,
      minDay,
      maxDay
    );
  }

  Widget _buildLineChart(List<FlSpot> spots, Color lineColor) {
    if (spots.isEmpty) {
      return Center(child: Text('no_data_for_this_month'.tr));
    }

    final double maxAmount = spots
        .map((spot) => spot.y)
        .fold(0.0, (max, current) => max > current ? max : current);
    final double maxY =
        maxAmount > 0 ? (maxAmount * 1.4).round().toDouble() : 100;

    // Lấy min và max day từ spots
    final double minDay = spots.map((s) => s.x).reduce(min);
    final double maxDay = spots.map((s) => s.x).reduce(max);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0) {
                  return const Text('0', style: TextStyle(fontSize: 10));
                }
                if (value >= 1000) {
                  return Text('${(value / 1000).toStringAsFixed(0)}k',
                      style: AppTextStyles.caption);
                }
                return Text(value.toStringAsFixed(0),
                    style: AppTextStyles.caption);
              },
              reservedSize: 35,
              interval: maxY / 4,
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: max(1, ((maxDay - minDay) / 6).ceil().toDouble()),
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value < minDay || value > maxDay) return const Text('');
                return SideTitleWidget(
                    meta: meta,
                    child:
                        Text('${value.toInt()}', style: AppTextStyles.caption));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: minDay,
        maxX: maxDay,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.transparent),
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
            Text('recent_transactions'.tr,
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textDefault)),
            // TextButton(
            //   onPressed: () {
            //     widget.onScreenChanged(1);
            //   },
            //   child: Text('see_all'.tr,
            //       style: AppTextStyles.subtitle.copyWith(color: Colors.green)),
            // ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final transactionController = Get.find<TransactionController>();
          final recentTransactions =
              transactionController.transactions.take(5).toList();
          if (recentTransactions.isEmpty) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('no_recent_transactions'.tr)));
          }
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                final transaction = recentTransactions[index];
                return Column(
                  children: [
                    _buildTransactionItem(transaction),
                    if (index != recentTransactions.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0XFFF0F1FA),
                      ),
                  ],
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Color(transaction.colorValue).withAlpha(25),
          child: SvgPicture.asset(transaction.iconPath, width: 28, height: 28),
        ),
        title: Text(
          transaction.categoryName.tr,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          transaction.title.isNotEmpty
              ? transaction.title
              : DateFormat('d MMMM yyyy').format(transaction.date),
          style: AppTextStyles.caption,
        ),
        trailing: Obx(() {
          final appController = Get.find<AppController>();
          return Text(
            '${transaction.type == TransactionType.income ? '+' : '-'}${appController.currencySymbol}${transaction.amount.toStringAsFixed(0)}',
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
