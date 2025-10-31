import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:money_manager/providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, WalletProvider>(
        builder: (context, transactionProvider, walletProvider, child) {
          final allTransactions = transactionProvider.transactions;

          // Filter transactions based on the selected wallet
          final transactions = _selectedWallet == 'Total'
              ? allTransactions
              : allTransactions.where((tx) => tx.walletId == _selectedWallet).toList();

          // Calculate totals for the days visible in the calendar
          final dailyTotals = groupBy(transactions, (Transaction tx) => DateTime(tx.date.year, tx.date.month, tx.date.day))
              .map((date, txs) {
                  final income = txs.where((tx) => tx.type == TransactionType.income).fold(0.0, (sum, item) => sum + item.amount);
                  final expense = txs.where((tx) => tx.type == TransactionType.expense).fold(0.0, (sum, item) => sum + item.amount);
                  return MapEntry(date, {'income': income, 'expense': expense});
              });

          // Group transactions for the list view
          final groupedTransactions = groupBy(
            transactions,
            (Transaction tx) => DateTime(tx.date.year, tx.date.month, tx.date.day),
          );
          final sortedDates = groupedTransactions.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          final totalIncome = transactions.where((tx) => tx.type == TransactionType.income).fold(0.0, (sum, item) => sum + item.amount);
          final totalExpense = transactions.where((tx) => tx.type == TransactionType.expense).fold(0.0, (sum, item) => sum + item.amount);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(walletProvider),
                _buildCalendar(dailyTotals),
                _buildSummary(totalIncome, totalExpense),
                _buildTransactionList(sortedDates, groupedTransactions),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onScreenChanged(2),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(WalletProvider walletProvider) {
    List<DropdownMenuItem<String>> walletItems = [
      const DropdownMenuItem(value: 'Total', child: Text('Total')),
      ...walletProvider.wallets.map((wallet) {
        return DropdownMenuItem(
          value: wallet.id,
          child: Text(wallet.name),
        );
      }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: DateFormat('MM/yyyy').format(_focusedDay),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                items: [], // Placeholder for month/year picker
                onChanged: (value) {
                  // TODO: Implement month/year picker
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5)],
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

  Widget _buildCalendar(Map<DateTime, Map<String, double>> dailyTotals) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
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
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final totals = dailyTotals[DateTime(day.year, day.month, day.day)];
            final income = totals?['income'] ?? 0;
            final expense = totals?['expense'] ?? 0;
            return Container(
              margin: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${day.day}', style: const TextStyle(fontSize: 16)),
                  if (expense > 0)
                    Text('-\$${expense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 10)),
                  if (income > 0)
                    Text('+\$${income.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontSize: 10)),
                ],
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return Container(
               margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
            todayBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },

        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
      ),
    );
  }

  Widget _buildSummary(double income, double expense) {
    final total = income - expense;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Income', income, Colors.blue),
          _buildSummaryItem('Expenses', expense, Colors.red),
          _buildSummaryItem('Total', total, total >= 0 ? Colors.green : Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        const SizedBox(height: 4.0),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTransactionList(List<DateTime> sortedDates, Map<DateTime, List<Transaction>> groupedTransactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dailyTransactions = groupedTransactions[date]!;
        final dailyTotal = dailyTransactions.fold(0.0, (sum, tx) {
          return sum + (tx.type == TransactionType.income ? tx.amount : -tx.amount);
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey[700]),
                  ),
                  Text(
                    '${dailyTotal >= 0 ? '+' : ''}\$${dailyTotal.abs().toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            ...dailyTransactions.map((tx) => _buildTransactionItem(context, tx)),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(transaction.colorValue).withOpacity(0.1),
          child: Image.asset(transaction.iconPath, width: 24, height: 24),
        ),
        title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.type == TransactionType.income ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == TransactionType.income ? Colors.blue : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
        onTap: () {
          // TODO: Implement transaction details navigation
        },
      ),
    );
  }
}
