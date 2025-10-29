import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/screens/currency_selection_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? _selectedLocale;

  final Map<String, String> _languages = {
    'en': 'English',
    'fr': 'Français',
    'vi': 'Tiếng Việt',
  };

  @override
  void initState() {
    super.initState();
    _selectedLocale = Provider.of<AppProvider>(context, listen: false).locale;
  }

  void _onNext() async {
    if (_selectedLocale != null) {
      // Update provider
      Provider.of<AppProvider>(context, listen: false).setLocale(_selectedLocale!);

      // Save selection
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _selectedLocale!.languageCode);

      // Navigate to the next step of the setup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CurrencySelectionScreen(isInitialSetup: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView( // Changed from ListView.builder
              children: _languages.entries.map((entry) {
                return RadioListTile<Locale>(
                  title: Text(entry.value),
                  value: Locale(entry.key, ''),
                  groupValue: _selectedLocale,
                  onChanged: (Locale? value) {
                    setState(() {
                      _selectedLocale = value;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedLocale != null ? _onNext : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
