import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:get/get.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/screens/transaction_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';

import 'add_transaction_screen.dart';

class RecordScreen extends StatefulWidget {
  final Function(int) onScreenChanged;

  const RecordScreen({super.key, required this.onScreenChanged});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedWallet = 'Total';
  late List<DateTime> _months;

  @override
  void initState() {
    super.initState();
    _selectedDay = null; // Default to showing the whole month
    _months = _getMonths();
  }

  List<DateTime> _getMonths() {
    final now = DateTime.now();
    final firstMonth = DateTime(now.year - 2, now.month);
    final lastMonth = DateTime(now.year + 1, now.month);
    final months = <DateTime>[];
    DateTime currentMonth = firstMonth;
    while (currentMonth.isBefore(lastMonth) ||
        currentMonth.isAtSameMomentAs(lastMonth)) {
      months.add(currentMonth);
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = Get.find();
    final AppController appController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('record'.tr,
            style: AppTextStyles.title.copyWith(
                color: Colors.black, fontWeight: FontWeight.bold)),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search, color: Colors.black54),
        //     onPressed: () {
        //       // TODO: Implement search functionality
        //     },
        //   ),
        // ],
      ),
      body: Obx(() {
        final allTransactions = transactionController.transactions;

        final monthlyTransactions = allTransactions.where((tx) {
          final walletMatch =
              _selectedWallet == 'Total' || tx.walletId == _selectedWallet;
          final monthMatch = tx.date.year == _focusedDay.year &&
              tx.date.month == _focusedDay.month;
          return walletMatch && monthMatch;
        }).toList();

        final dailyTotals = groupBy(
          allTransactions,
          (Transaction tx) =>
              DateTime(tx.date.year, tx.date.month, tx.date.day),
        ).map((date, txs) {
          final income = txs
              .where((tx) => tx.type == TransactionType.income)
              .fold(0.0, (sum, item) => sum + item.amount);
          final expense = txs
              .where((tx) => tx.type == TransactionType.expense)
              .fold(0.0, (sum, item) => sum + item.amount);
          return MapEntry(date, {'income': income, 'expense': expense});
        });

        final groupedTransactions = groupBy(
          monthlyTransactions,
          (Transaction tx) =>
              DateTime(tx.date.year, tx.date.month, tx.date.day),
        );
        final sortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        final totalIncome = monthlyTransactions
            .where((tx) => tx.type == TransactionType.income)
            .fold(0.0, (sum, item) => sum + item.amount);
        final totalExpense = monthlyTransactions
            .where((tx) => tx.type == TransactionType.expense)
            .fold(0.0, (sum, item) => sum + item.amount);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetBuilder<WalletController>(
                builder: (walletController) {
                  return _buildHeader(walletController);
                },
              ),
              _buildCalendar(dailyTotals, appController),
              const SizedBox(height: 16),
              _buildSummary(totalIncome, totalExpense),
              _buildTransactionList(
                  sortedDates, groupedTransactions, appController),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddTransactionScreen());
        },
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(WalletController walletController) {
    List<DropdownMenuItem<String>> walletItems = [
      DropdownMenuItem(
          value: 'Total', child: Text('total'.tr, style: AppTextStyles.body)),
      // Dịch
      ...walletController.wallets.map((wallet) {
        return DropdownMenuItem(
          value: wallet.id,
          child: Text(wallet.name, style: AppTextStyles.body),
        );
      }),
    ];

    DateTime selectedMonth = _months.firstWhere(
        (month) =>
            month.year == _focusedDay.year && month.month == _focusedDay.month,
        orElse: () => _months.firstWhere(
            (m) =>
                m.year == DateTime.now().year &&
                m.month == DateTime.now().month,
            orElse: () => _months.first));

    return Container(
      decoration: BoxDecoration(
        color: Color(0XFF2C3E64),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DateTime>(
                value: selectedMonth,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                items: _months.map((DateTime month) {
                  return DropdownMenuItem<DateTime>(
                    value: month,
                    child: Text(DateFormat('MMMM yyyy').format(month),
                        style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (DateTime? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _focusedDay = newValue;
                      _selectedDay = null;
                    });
                  }
                },
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedWallet,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                items: walletItems,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedWallet = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, Map<String, double>> dailyTotals,
      AppController appController) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
      child: TableCalendar(
        headerVisible: false,
        firstDay: _months.first,
        lastDay: _months.last,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
            _selectedDay = null;
          });
        },
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.body
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          weekendStyle: AppTextStyles.body
              .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final totals = dailyTotals[DateTime(day.year, day.month, day.day)];
            final income = totals?['income'] ?? 0;
            final expense = totals?['expense'] ?? 0;
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${day.day}',
                      style: AppTextStyles.caption.copyWith(fontSize: 12)),
                  if (income > 0)
                    Text(
                        '+${appController.currencySymbol}${income.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.blue,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  if (expense > 0)
                    Text(
                        '-${appController.currencySymbol}${expense.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            final totals = dailyTotals[DateTime(day.year, day.month, day.day)];
            final income = totals?['income'] ?? 0;
            final expense = totals?['expense'] ?? 0;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(75),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${day.day}',
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                  if (income > 0)
                    Text(
                        '+${appController.currencySymbol}${income.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.blue,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  if (expense > 0)
                    Text(
                        '-${appController.currencySymbol}${expense.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final totals = dailyTotals[DateTime(day.year, day.month, day.day)];
            final income = totals?['income'] ?? 0;
            final expense = totals?['expense'] ?? 0;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 1.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${day.day}',
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                  if (income > 0)
                    Text(
                        '+${appController.currencySymbol}${income.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.blue,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  if (expense > 0)
                    Text(
                        '-${appController.currencySymbol}${expense.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(double income, double expense) {
    final total = expense - income;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('income'.tr, income, Colors.blue),
          // Dịch
          _buildSummaryItem('expenses'.tr, expense, Colors.red),
          // Dịch
          _buildSummaryItem(
              'total'.tr, total, total >= 0 ? Colors.green : Colors.orange),
          // Dịch
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title,
            style: AppTextStyles.body
                .copyWith(color: Colors.grey[600], fontSize: 16)),
        const SizedBox(height: 4.0),
        Obx(() {
          final appController = Get.find<AppController>();
          return Text(
            '${appController.currencySymbol}${amount.toStringAsFixed(2)}',
            style: AppTextStyles.body.copyWith(
                color: color, fontWeight: FontWeight.bold, fontSize: 18),
          );
        }),
      ],
    );
  }

  Widget _buildTransactionList(
      List<DateTime> sortedDates,
      Map<DateTime, List<Transaction>> groupedTransactions,
      AppController appController) {
    if (_selectedDay != null) {
      final selectedDayKey =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      final selectedDayTransactions = groupedTransactions[selectedDayKey] ?? [];

      if (selectedDayTransactions.isEmpty) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('no_transactions_on_this_day'.tr,
                    style: AppTextStyles.body))); // Dịch
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Text(
              DateFormat('dd/MM/yyyy').format(selectedDayKey),
              style: AppTextStyles.title
                  .copyWith(fontSize: 18, color: Colors.grey[700]),
            ),
          ),
          ...selectedDayTransactions
              .map((tx) => _buildTransactionItem(context, tx))
        ],
      );
    } else {
      if (groupedTransactions.isEmpty) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text('no_transactions_in_this_month'.tr,
                    style: AppTextStyles.body))); // Dịch
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dailyTransactions = groupedTransactions[date]!;
          final dailyTotal = dailyTransactions.fold(0.0, (sum, tx) {
            return sum +
                (tx.type == TransactionType.income ? tx.amount : -tx.amount);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(date),
                      style: AppTextStyles.title
                          .copyWith(fontSize: 18, color: Colors.grey[700]),
                    ),
                    Text(
                      '${dailyTotal >= 0 ? '+' : ''}${appController.currencySymbol}${dailyTotal.abs().toStringAsFixed(2)}',
                      style: AppTextStyles.title
                          .copyWith(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              ...dailyTransactions
                  .map((tx) => _buildTransactionItem(context, tx)),
              const SizedBox(height: 10),
            ],
          );
        },
      );
    }
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Color(transaction.colorValue).withAlpha(25),
          child: SvgPicture.asset(transaction.iconPath, width: 22, height: 22),
        ),
        title: Text(transaction.categoryName.tr,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        subtitle: transaction.title.isNotEmpty
            ? Text(transaction.title, style: AppTextStyles.caption)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final appController = Get.find<AppController>();
              return Text(
                '${transaction.type == TransactionType.income ? '+' : '-'}${appController.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                style: AppTextStyles.body.copyWith(
                    color: transaction.type == TransactionType.income
                        ? Colors.blue
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              );
            }),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
        onTap: () {
          Get.to(() => TransactionDetailScreen(transaction: transaction));
        },
      ),
    );
  }
}
