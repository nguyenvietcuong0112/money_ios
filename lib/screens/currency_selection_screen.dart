import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/main.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final bool isInitialSetup;

  const CurrencySelectionScreen({super.key, this.isInitialSetup = false});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String? _selectedCurrencyCode;
  final List<Currency> _currencies = CurrencyService().getAll();

  @override
  void initState() {
    super.initState();
    _selectedCurrencyCode = Get.find<AppController>().currency;
  }

  void _onNext() async {
    if (_selectedCurrencyCode != null) {
      // Update controller
      Get.find<AppController>().setCurrency(_selectedCurrencyCode!);

      if (widget.isInitialSetup) {
        // Save the flag that setup is complete
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstTime', false);
        await prefs.setString('currency', _selectedCurrencyCode!);

        // Navigate to the main app screen and remove the setup screens from the stack
        Get.offAll(() => const MyHomePage());
      } else {
        // Just pop the screen if coming from settings
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        automaticallyImplyLeading: !widget.isInitialSetup,
        actions: [
          if (_selectedCurrencyCode != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _onNext,
              tooltip: widget.isInitialSetup ? 'Next' : 'Save',
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          final currency = _currencies[index];
          final isSelected = currency.code == _selectedCurrencyCode;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCurrencyCode = currency.code;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(30) : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 4.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(currency.symbol, style: const TextStyle(fontSize: 24.0)),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currency.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(currency.code),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
