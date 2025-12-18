
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/common/utils.dart';

class ToCurrencyScreen extends StatefulWidget {
  final List<Currency> selectedCurrencies;

  const ToCurrencyScreen({super.key, required this.selectedCurrencies});

  @override
  _ToCurrencyScreenState createState() => _ToCurrencyScreenState();
}

class _ToCurrencyScreenState extends State<ToCurrencyScreen> {
  final _searchController = TextEditingController();
  List<Currency> _filteredCurrencies = [];
  List<Currency> _selectedCurrencies = [];

  @override
  void initState() {
    super.initState();
    _selectedCurrencies.addAll(widget.selectedCurrencies);
    _filteredCurrencies = CurrencyService().getAll();
    _searchController.addListener(_filterCurrencies);
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = CurrencyService().getAll().where((c) {
        return c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleCurrencySelection(Currency currency) {
    setState(() {
      if (_selectedCurrencies.any((c) => c.code == currency.code)) {
        _selectedCurrencies.removeWhere((c) => c.code == currency.code);
      } else {
        _selectedCurrencies.add(currency);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Currency'.tr, style: AppTextStyles.title.copyWith(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF4F46E5)),
            onPressed: () => Get.back(result: _selectedCurrencies),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'search'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = _filteredCurrencies[index];
                  final isSelected = _selectedCurrencies.any((c) => c.code == currency.code);
                  return ListTile(
                    leading: Text(Utils.currencyToEmoji(currency), style: const TextStyle(fontSize: 24)),
                    title: Text(currency.code, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(currency.name, style: AppTextStyles.body.copyWith(color: Colors.grey)),
                    trailing: isSelected
                        ? const Icon(Icons.radio_button_checked, color: Color(0xFF4F46E5))
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: () => _toggleCurrencySelection(currency),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
