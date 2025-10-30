import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:money_manager/screens/add_transaction_screen.dart';
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
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          _events = {};
          for (var transaction in transactionProvider.transactions) {
            final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
            if (_events[day] == null) {
              _events[day] = [];
            }
            _events[day]!.add(transaction);
          }

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
                Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade200, width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TableCalendar(
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
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                      weekendStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    calendarBuilders: CalendarBuilders(
                      dowBuilder: (context, day) {
                        if (day.weekday == DateTime.sunday) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                            ),
                            child: Center(
                              child: Text(
                                DateFormat.E().format(day),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        } else {
                           return Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                            ),
                            child: Center(
                              child: Text(
                                DateFormat.E().format(day),
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }
                      },
                      markerBuilder: (context, date, events) {
                        return const SizedBox.shrink();
                      },
                    ),

                    headerVisible: false,

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Income', '${transactionProvider.totalIncome.toStringAsFixed(0)} ${appProvider.currencySymbol}', Colors.blue),
                      _buildSummaryItem('Expenses', '${transactionProvider.totalExpense.toStringAsFixed(0)} ${appProvider.currencySymbol}', Colors.red),
                      _buildSummaryItem('Total', '${(transactionProvider.totalIncome - transactionProvider.totalExpense).toStringAsFixed(0)} ${appProvider.currencySymbol}', Colors.black),
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
                        leading: Icon(transaction.icon, color: transaction.color),
                        title: Text(transaction.title),
                        trailing: Text(
                          '${transaction.type == TransactionType.income ? '+' : '-'}${appProvider.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(color: transaction.type == TransactionType.income ? Colors.green : Colors.red),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
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
