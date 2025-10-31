import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/providers/transaction_provider.dart';
import 'package:money_manager/providers/wallet_provider.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/wallet_model.dart';
import 'dart:math';

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
              final totalBalance = walletProvider.getTotalBalance();
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
              onPressed: () { /* TODO: Navigate to Wallets Screen */ },
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
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(wallet.colorValue).withOpacity(0.1),
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

                      final data = _tabController.index == 0 
                          ? _prepareChartData(monthTransactions, TransactionType.expense)
                          : _prepareChartData(monthTransactions, TransactionType.income);

                      final totalAmount = (_tabController.index == 0 ? data.item2 : data.item3);


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
                          Expanded(child: _buildLineChart(data.item1, _tabController.index == 0 ? Colors.red : Colors.blue)),
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


  Tuple3<List<FlSpot>, double, double> _prepareChartData(List<Transaction> transactions, TransactionType type) {
      final filtered = transactions.where((tx) => tx.type == type).toList();
      final totalAmount = filtered.fold(0.0, (sum, item) => sum + item.amount);

      final dataByDay = groupBy(filtered, (Transaction tx) => tx.date.day);

      List<FlSpot> spots = [];
      for (var day = 1; day <= DateTime.now().day; day++) {
        if (dataByDay.containsKey(day)) {
          final dayTotal = dataByDay[day]!.fold(0.0, (sum, item) => sum + item.amount);
          spots.add(FlSpot(day.toDouble(), dayTotal));
        } else {
          spots.add(FlSpot(day.toDouble(), 0)); // Add zero if no transactions for that day
        }
      }
      if (spots.isEmpty) {
        spots.add(const FlSpot(1, 0));
      }

      final totalExpense = transactions.where((tx) => tx.type == TransactionType.expense).fold(0.0, (sum, item) => sum + item.amount);
      final totalIncome = transactions.where((tx) => tx.type == TransactionType.income).fold(0.0, (sum, item) => sum + item.amount);


      return Tuple3(spots, totalExpense, totalIncome);
  }



  Widget _buildLineChart(List<FlSpot> spots, Color lineColor) {
    if (spots.isEmpty) {
      return const Center(child: Text('No data for this month.'));
    }
    
    final double maxAmount = spots.map((spot) => spot.y).reduce(max);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10,
                  child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                );
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
        const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Color(transaction.colorValue).withOpacity(0.1),
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

class Tuple3<T1, T2, T3> {
  final T1 item1;
  final T2 item2;
  final T3 item3;

  Tuple3(this.item1, this.item2, this.item3);
}
