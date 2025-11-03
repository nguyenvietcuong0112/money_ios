import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/main.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final bool isInitialSetup;

  const CurrencySelectionScreen({super.key, this.isInitialSetup = false});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  final List<Currency> _allCurrencies = CurrencyService().getAll();
  late List<Currency> _filteredCurrencies;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = _allCurrencies;
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCurrencies);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = _allCurrencies.where((c) {
        return c.name.toLowerCase().contains(query) ||
               c.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();

    void _onSelect(Currency currency) {
      appController.setCurrency(currency.code, currency.symbol);
      if (widget.isInitialSetup) {
        Get.offAll(() => const MyHomePage());
      } else {
        Get.back();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        automaticallyImplyLeading: !widget.isInitialSetup,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search by currency name or code',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                return ListTile(
                  title: Text(currency.name),
                  subtitle: Text(currency.code),
                  trailing: Text(currency.symbol, style: const TextStyle(fontSize: 18)),
                  onTap: () => _onSelect(currency),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
