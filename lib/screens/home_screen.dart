import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:money_manager/providers/wallet_provider.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'dart:math';
import 'package:collection/collection.dart';

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
        title: const Text('Home', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              final totalBalance = walletProvider.totalBalance;
              return Row(
                children: [
                  Text(
                    _isBalanceVisible ? '\$${totalBalance.toStringAsFixed(2)}' : '*********',
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
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
            },
          ),
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
    );
  }

  Widget _buildMyWalletsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Wallets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () { widget.onScreenChanged(2); },
              child: const Text('See all', style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Consumer<WalletProvider>(
          builder: (context, walletProvider, child) {
            if (walletProvider.wallets.isEmpty) {
              return const Text("No wallets available. Add one!");
            }
            return SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: min(4, walletProvider.wallets.length),
                itemBuilder: (context, index) {
                  final wallet = walletProvider.wallets[index];
                  return _buildWalletCard(wallet);
                },
              ),
            );
          },
        ),
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
    final color = _getWalletColor(wallet.name);
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
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Image.asset(wallet.iconPath, width: 24, height: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  _isBalanceVisible ? '\$${wallet.balance.toStringAsFixed(2)}' : '***',
                  style: TextStyle(fontSize: 12, color: wallet.balance < 0 ? Colors.red : Colors.black),
                ),
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
        const Text('Report this month', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                tabs: const [
                  Tab(text: 'Total Expense'),
                  Tab(text: 'Total Income'),
                ],
                onTap: (index) {
                    setState(() {}); // Rebuild to update chart
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Consumer<TransactionProvider>(
                  builder: (context, transactionProvider, child) {
                      final now = DateTime.now();
                      final monthTransactions = transactionProvider.transactions.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList();

                      final data = _prepareChartData(monthTransactions);

                      final chartData = _tabController.index == 0 ? data.item1 : data.item2; // item1 for expense, item2 for income
                      final totalAmount = _tabController.index == 0 ? data.item3 : data.item4; // item3 for expense total, item4 for income total


                      return Column(
                        children: [
                           Align(
                            alignment: Alignment.centerLeft,
                             child: Text(
                                '${_tabController.index == 0 ? '-' : '+'}\$${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold, 
                                  color: _tabController.index == 0 ? Colors.red : Colors.blue
                                ),
                              ), 
                           ),
                          const SizedBox(height: 10),
                          Expanded(child: _buildLineChart(chartData, _tabController.index == 0 ? Colors.red : Colors.blue)),
                        ],
                      );
                  }
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Tuple4<List<FlSpot>, List<FlSpot>, double, double> _prepareChartData(List<Transaction> transactions) {
      // Prepare Expense Data
      final expenseTransactions = transactions.where((tx) => tx.type == TransactionType.expense).toList();
      final totalExpense = expenseTransactions.fold(0.0, (sum, item) => sum + item.amount);
      final expenseDataByDay = groupBy(expenseTransactions, (Transaction tx) => tx.date.day);
      List<FlSpot> expenseSpots = [];
      for (var day = 1; day <= DateTime.now().day; day++) {
        final dayTotal = expenseDataByDay[day]?.fold(0.0, (sum, item) => sum + item.amount) ?? 0.0;
        expenseSpots.add(FlSpot(day.toDouble(), dayTotal));
      }
      if (expenseSpots.isEmpty) expenseSpots.add(const FlSpot(1, 0));

      // Prepare Income Data
      final incomeTransactions = transactions.where((tx) => tx.type == TransactionType.income).toList();
      final totalIncome = incomeTransactions.fold(0.0, (sum, item) => sum + item.amount);
      final incomeDataByDay = groupBy(incomeTransactions, (Transaction tx) => tx.date.day);
      List<FlSpot> incomeSpots = [];
      for (var day = 1; day <= DateTime.now().day; day++) {
        final dayTotal = incomeDataByDay[day]?.fold(0.0, (sum, item) => sum + item.amount) ?? 0.0;
        incomeSpots.add(FlSpot(day.toDouble(), dayTotal));
      }
       if (incomeSpots.isEmpty) incomeSpots.add(const FlSpot(1, 0));

      return Tuple4(expenseSpots, incomeSpots, totalExpense, totalIncome);
  }


  Widget _buildLineChart(List<FlSpot> spots, Color lineColor) {
    if (spots.isEmpty) {
      return const Center(child: Text('No data for this month.'));
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
                  case 1:
                    text = const Text('1');
                    break;
                  case 5:
                    text = const Text('5');
                    break;
                  case 10:
                    text = const Text('10');
                    break;
                  case 15:
                    text = const Text('15');
                    break;
                  case 20:
                    text = const Text('20');
                    break;
                  case 25:
                    text = const Text('25');
                    break;
                  case 30:
                    text = const Text('30');
                    break;
                  default:
                    text = const Text('');
                    break;
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
        maxY: maxAmount * 1.2, // Add some padding
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
                const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () { widget.onScreenChanged(1); },
                    child: const Text('See all', style: TextStyle(color: Colors.green, fontSize: 16)),
                ),
            ],
        ),
        const SizedBox(height: 10),
        Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            final recentTransactions = transactionProvider.transactions.take(5).toList();
            if (recentTransactions.isEmpty) {
              return const Text("No recent transactions.");
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
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final wallet = walletProvider.getWalletById(transaction.walletId);
    final color = wallet != null ? _getWalletColor(wallet.name) : Colors.grey;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.1),
          child: Image.asset(transaction.iconPath, width: 28, height: 28),
        ),
        title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('d MMMM yyyy').format(transaction.date)),
        trailing: Text(
          '${transaction.type == TransactionType.income ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.type == TransactionType.income ? Colors.blue : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO: Navigate to transaction details
        },
      ),
    );
  }
}

class Tuple4<T1, T2, T3, T4> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  final T4 item4;

  Tuple4(this.item1, this.item2, this.item3, this.item4);
}
