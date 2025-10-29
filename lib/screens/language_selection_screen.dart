import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/screens/currency_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                appProvider.setLocale(const Locale('en', ''));
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('language_code', 'en');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
                );
              },
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () async {
                appProvider.setLocale(const Locale('vi', ''));
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('language_code', 'vi');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
                );
              },
              child: const Text('Tiếng Việt'),
            ),
            ElevatedButton(
              onPressed: () async {
                appProvider.setLocale(const Locale('fr', ''));
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('language_code', 'fr');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
                );
              },
              child: const Text('Français'),
            ),
          ],
        ),
      ),
    );
  }
}
