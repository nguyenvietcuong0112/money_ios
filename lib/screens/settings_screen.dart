import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_manager/providers/theme_provider.dart';
import 'package:money_manager/providers/app_provider.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/screens/language_selection_screen.dart';
import 'package:money_manager/screens/currency_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final localizations = AppLocalizations.of(context);

    // It's safer to handle the case where localizations might not be ready.
    if (localizations == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings') ?? 'Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(localizations.translate('dark_mode') ?? 'Dark Mode'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            title: Text(localizations.translate('language') ?? 'Language'),
            trailing: Text(appProvider.locale?.languageCode ?? ''),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
              );
            },
          ),
          ListTile(
            title: Text(localizations.translate('currency') ?? 'Currency'),
            trailing: Text(appProvider.currency ?? ''),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
