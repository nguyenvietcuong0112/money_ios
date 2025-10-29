import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencySelectionScreen extends StatelessWidget {
  const CurrencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showCurrencyPicker(
              context: context,
              showFlag: true,
              showCurrencyName: true,
              showCurrencyCode: true,
              onSelect: (Currency currency) async {
                appProvider.setCurrency(currency.code);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('currency_code', currency.code);
                await prefs.setBool('is_setup_complete', true);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              },
            );
          },
          child: const Text('Select Currency'),
        ),
      ),
    );
  }
}
