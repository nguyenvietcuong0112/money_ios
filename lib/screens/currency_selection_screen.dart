
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/main.dart'; // Import to access MyHomePage

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
    _selectedCurrencyCode = Provider.of<AppProvider>(context, listen: false).currency;
  }

  void _onNext() async {
    if (_selectedCurrencyCode != null) {
      // Update provider
      Provider.of<AppProvider>(context, listen: false).setCurrency(_selectedCurrencyCode!);

      if (widget.isInitialSetup) {
        // Save the flag that setup is complete
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstTime', false);
        await prefs.setString('currency', _selectedCurrencyCode!);

        if (!mounted) return;
        // Navigate to the main app screen and remove the setup screens from the stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        // Just pop the screen if coming from settings
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        automaticallyImplyLeading: !widget.isInitialSetup, // Hide back button on initial setup
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
          return RadioListTile<String>(
            title: Text('${currency.name} (${currency.code})'),
            subtitle: Text(currency.symbol),
            value: currency.code,
            groupValue: _selectedCurrencyCode,
            onChanged: (String? value) {
              setState(() {
                _selectedCurrencyCode = value;
              });
            },
          );
        },
      ),
    );
  }
}
