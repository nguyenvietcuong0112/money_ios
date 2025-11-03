import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
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
  Currency? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = _allCurrencies;
    final appController = Get.find<AppController>();
    if (appController.currency.isNotEmpty) {
      _selectedCurrency = _allCurrencies.firstWhere(
        (c) => c.code == appController.currency,
        orElse: () => _allCurrencies.first,
      );
    }
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
        return c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onConfirm() {
    if (_selectedCurrency != null) {
      final AppController appController = Get.find();
      appController.setCurrency(_selectedCurrency!.code, _selectedCurrency!.symbol);
      if (widget.isInitialSetup) {
        Get.offAll(() => const MyHomePage());
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Currency', style: AppTextStyles.title),
        automaticallyImplyLeading: !widget.isInitialSetup,
        actions: [
          TextButton(
            onPressed: _selectedCurrency == null ? null : _onConfirm,
            child: Text(
              'Next',
              style: AppTextStyles.button.copyWith(
                color: _selectedCurrency == null
                    ? Colors.grey
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: AppTextStyles.body,
                hintText: 'Search by currency name or code',
                hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
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
                final isSelected = _selectedCurrency?.code == currency.code;
                return ListTile(
                  title: Text(currency.name, style: AppTextStyles.body),
                  subtitle: Text(currency.code, style: AppTextStyles.caption),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : Text(currency.symbol, style: AppTextStyles.body.copyWith(fontSize: 18)),
                  tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
                  onTap: () {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
