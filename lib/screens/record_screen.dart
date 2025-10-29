import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/providers/budget_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  Map<DateTime, List<Transaction>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Transaction> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          _events = budgetProvider.getTransactionsByMonth(_focusedDay);

          final monthlySummary = budgetProvider.getMonthlySummary(_focusedDay);
          final selectedDayTransactions = _getEventsForDay(_selectedDay!);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('MM/yyyy').format(_focusedDay),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () {
                              _selectDate(context);
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.account_balance_wallet, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerVisible: false,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        final summary = budgetProvider.getDailySummary(events as List<Transaction>);
                        return Positioned(
                          bottom: 1,
                          child: Column(
                            children: [
                              if (summary['income']! > 0)
                                Text(
                                  '+${summary['income']!.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.green, fontSize: 10),
                                ),
                              if (summary['expense']! > 0)
                                Text(
                                  '-${summary['expense']!.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.red, fontSize: 10),
                                ),
                            ],
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Income', '${monthlySummary['income']!.toStringAsFixed(0)} ${appProvider.currencySymbol}', Colors.blue),
                      _buildSummaryItem('Expenses', '${monthlySummary['expense']!.toStringAsFixed(0)} ${appProvider.currencySymbol}', Colors.red),
                      _buildSummaryItem('Total', '${(monthlySummary['income']! - monthlySummary['expense']!).toStringAsFixed(0)} ${appProvider.currencySymbol}', Colors.black),
                    ],
                  ),
                ),
                const Divider(),
                if (selectedDayTransactions.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedDayTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = selectedDayTransactions[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(transaction.category),
                        subtitle: Text(transaction.note ?? ''),
                        trailing: Text(
                          '${transaction.type == 'income' ? '+' : '-'}${appProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(color: transaction.type == 'income' ? Colors.green : Colors.red),
                        ),
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No transactions for this day.'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _focusedDay) {
      setState(() {
        _focusedDay = picked;
      });
    }
  }

  Widget _buildSummaryItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
