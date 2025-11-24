import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:get/get.dart';
import 'package:money_manager/controllers/transaction_controller.dart';
import 'package:money_manager/controllers/wallet_controller.dart';
import 'package:money_manager/screens/transaction_detail_screen.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
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
  String _selectedWalletId = 'Total'; // Đổi tên và set default là 'Total'
  late List<DateTime> _months;
  final walletController = Get.find<WalletController>();

  @override
  void initState() {
    super.initState();
    _selectedDay = null;
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
            style: AppTextStyles.title
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        final allTransactions = transactionController.transactions;

        // Lọc transactions theo wallet và tháng
        final monthlyTransactions = allTransactions.where((tx) {
          final walletMatch =
              _selectedWalletId == 'Total' || tx.walletId == _selectedWalletId;
          final monthMatch = tx.date.year == _focusedDay.year &&
              tx.date.month == _focusedDay.month;
          return walletMatch && monthMatch;
        }).toList();

        // Tính dailyTotals có lọc theo wallet
        final dailyTotals = groupBy(
          allTransactions.where((tx) {
            final walletMatch = _selectedWalletId == 'Total' ||
                tx.walletId == _selectedWalletId;
            return walletMatch;
          }),
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
              SizedBox(height: 2.h),
              _buildSummary(totalIncome, totalExpense),
              _buildTransactionList(
                  sortedDates, groupedTransactions, appController),
            ],
          ),
        );
      }),
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

  Widget _buildHeader(WalletController walletController) {
    DateTime selectedMonth = _months.firstWhere(
            (month) =>
        month.year == _focusedDay.year && month.month == _focusedDay.month,
        orElse: () => _months.firstWhere(
                (m) =>
            m.year == DateTime.now().year &&
                m.month == DateTime.now().month,
            orElse: () => _months.first));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0XFF2C3E64),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month Picker
          InkWell(
            onTap: () {
              showMonthPicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              ).then((date) {
                if (date != null) {
                  setState(() {
                    selectedMonth = date;
                    _focusedDay = date;
                    _selectedDay = null;
                  });
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textColorWhite),
                  ),
                  Icon(Icons.arrow_drop_down,
                      color: AppColors.textColorRed, size: 30.h),
                ],
              ),
            ),
          ),

          // Wallet Dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.textColorGreyContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() {
              // Build dropdown items: Total + all wallets
              List<DropdownMenuItem<String>> items = [
                DropdownMenuItem<String>(
                  value: 'Total',
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/ic_total.svg",
                        width: 24.w,
                        height: 24.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'total'.tr,
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                ...walletController.wallets.map((wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet.id,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          wallet.iconPath,
                          width: 24.w,
                          height: 24.h,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          wallet.name,
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ];

              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedWalletId,
                  icon: Icon(Icons.arrow_drop_down,
                      color: AppColors.textColorRed, size: 30.w),
                  items: items,
                  onChanged: (String? newWalletId) {
                    if (newWalletId != null) {
                      setState(() {
                        _selectedWalletId = newWalletId;
                      });
                    }
                  },
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, Map<String, double>> dailyTotals,
      AppController appController) {
    return Container(
      padding: EdgeInsets.only(top: 10.h),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: const BoxDecoration(color: Colors.white),
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
          weekdayStyle: AppTextStyles.body.copyWith(
              color: AppColors.textColorBlack, fontWeight: FontWeight.bold),
          weekendStyle: AppTextStyles.body.copyWith(
              color: AppColors.textColorRed, fontWeight: FontWeight.bold),
        ),
        daysOfWeekHeight: 30.h,
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
                            color: AppColors.textColorGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  if (expense > 0)
                    Text(
                        '-${appController.currencySymbol}${expense.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textColorRed,
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
                            color: AppColors.textColorGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  if (expense > 0)
                    Text(
                        '-${appController.currencySymbol}${expense.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textColorRed,
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
                  border: Border.all(color: Color(0XFF3E70FD), width: 1.5),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${day.day}',
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textColorBlack,
                          fontWeight: FontWeight.bold)),
                  if (income > 0)
                    Text(
                        '+${appController.currencySymbol}${income.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textColorGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  if (expense > 0)
                    Text(
                        '-${appController.currencySymbol}${expense.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textColorRed,
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.textColorWhite,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('income'.tr, income, AppColors.textColorGreen),
          _buildSummaryItem('expenses'.tr, expense, AppColors.textColorRed),
          _buildSummaryItem('total'.tr, total,
              total >= 0 ? AppColors.textColorBlue : AppColors.textColorBlue),
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
            '${appController.currencySymbol}${amount.toStringAsFixed(0)}',
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
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)
      ),
      margin: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
      child: _selectedDay != null
          ? Builder(
        builder: (context) {
          final selectedDayKey = DateTime(
              _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          final selectedDayTransactions =
              groupedTransactions[selectedDayKey] ?? [];

          if (selectedDayTransactions.isEmpty) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('no_transactions_on_this_day'.tr,
                        style: AppTextStyles.body)));
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
        },
      )
          : Builder(
        builder: (context) {
          if (groupedTransactions.isEmpty) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text('no_transactions_in_this_month'.tr,
                        style: AppTextStyles.body)));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dailyTransactions = groupedTransactions[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...dailyTransactions
                      .map((tx) => _buildTransactionItem(context, tx)),
                  const SizedBox(height: 10),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Color(transaction.colorValue).withAlpha(25),
          child: SvgPicture.asset(transaction.iconPath, width: 30, height: 30),
        ),
        title: Text(transaction.categoryName.tr,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          transaction.title.isNotEmpty
              ? transaction.title
              : DateFormat('d MMMM yyyy').format(transaction.date),),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final appController = Get.find<AppController>();
              return Text(
                '${transaction.amount.toStringAsFixed(0)}${appController.currencySymbol}',
                style: AppTextStyles.body.copyWith(
                    color: transaction.type == TransactionType.income
                        ? AppColors.textColorGreen
                        : AppColors.textColorRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              );
            }),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textColorBlue),
          ],
        ),
        onTap: () {
          Get.to(() => TransactionDetailScreen(transaction: transaction));
        },
      ),
    );
  }
}