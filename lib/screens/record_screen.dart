import 'package:flutter/material.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecordScreen extends StatefulWidget {
  final Function(int) onScreenChanged;

  const RecordScreen({super.key, required this.onScreenChanged});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isMonthSelected = true;
  DateTime _selectedDate = DateTime.now();

  void _changeDate(bool isNext) {
    setState(() {
      if (_isMonthSelected) {
        _selectedDate = DateTime(
          _selectedDate.year,
          isNext ? _selectedDate.month + 1 : _selectedDate.month - 1,
          _selectedDate.day,
        );
      } else {
        _selectedDate = DateTime(
          isNext ? _selectedDate.year + 1 : _selectedDate.year - 1,
          _selectedDate.month,
          _selectedDate.day,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevents the back button
        title: Text(localizations?.translate('records') ?? 'Records'),
      ),
      body: Column(
        children: [
          _buildDateNavigation(),
          const SizedBox(height: 16.0),
          _buildTotalSummary(context, localizations),
          const SizedBox(height: 16.0),
          _buildTransactionList(context, localizations),
        ],
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeDate(false),
          ),
          Column(
            children: [
              Text(
                _isMonthSelected
                    ? DateFormat.yMMM().format(_selectedDate)
                    : DateFormat.y().format(_selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Month'),
                    selected: _isMonthSelected,
                    onSelected: (selected) {
                      setState(() {
                        _isMonthSelected = true;
                      });
                    },
                  ),
                  const SizedBox(width: 8.0),
                  ChoiceChip(
                    label: const Text('Year'),
                    selected: !_isMonthSelected,
                    onSelected: (selected) {
                      setState(() {
                        _isMonthSelected = false;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeDate(true),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(BuildContext context, AppLocalizations? localizations) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Filter transactions based on the selected date period
    final transactionsInPeriod = transactionProvider.transactions.where((tx) {
      if (_isMonthSelected) {
        return tx.date.year == _selectedDate.year && tx.date.month == _selectedDate.month;
      } else {
        return tx.date.year == _selectedDate.year;
      }
    }).toList();

    final totalIncome = transactionsInPeriod
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);

    final totalExpense = transactionsInPeriod
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard(
            localizations?.translate('income') ?? 'Income',
            totalIncome,
            Colors.green,
            Icons.arrow_downward,
          ),
          _buildSummaryCard(
            localizations?.translate('expense') ?? 'Expense',
            totalExpense,
            Colors.red,
            Icons.arrow_upward,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8.0),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, AppLocalizations? localizations) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Filter transactions based on the selected date period
    final transactionsInPeriod = transactionProvider.transactions.where((tx) {
      if (_isMonthSelected) {
        return tx.date.year == _selectedDate.year && tx.date.month == _selectedDate.month;
      } else {
        return tx.date.year == _selectedDate.year;
      }
    }).toList();

    if (transactionsInPeriod.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(localizations?.translate('no_transactions') ?? 'No transactions for this period.'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: transactionsInPeriod.length,
        itemBuilder: (context, index) {
          final transaction = transactionsInPeriod[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(transaction.colorValue),
                child: Image.asset(transaction.iconPath, width: 24, height: 24),
              ),
              title: Text(transaction.title),
              subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
              trailing: Text(
                '${transaction.type == TransactionType.expense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.type == TransactionType.expense ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
