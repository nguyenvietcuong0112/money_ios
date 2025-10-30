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
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(localizations.translate('dark_mode') ?? 'Dark Mode'),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  secondary: const Icon(Icons.palette),
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, 'General'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(localizations.translate('language') ?? 'Language'),
                  trailing: Text(appProvider.locale?.languageCode ?? ''),
                  leading: const Icon(Icons.language),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(localizations.translate('currency') ?? 'Currency'),
                  trailing: Text(appProvider.currency!),
                  leading: const Icon(Icons.monetization_on),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, 'Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: false, // Replace with actual value
                  onChanged: (value) {
                    // Handle notification setting change
                  },
                  secondary: const Icon(Icons.notifications),
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, 'Security'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Set Passcode'),
                  leading: const Icon(Icons.lock),
                  onTap: () {
                    // Navigate to passcode screen
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Enable Fingerprint'),
                  value: false, // Replace with actual value
                  onChanged: (value) {
                    // Handle fingerprint setting change
                  },
                  secondary: const Icon(Icons.fingerprint),
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, 'Help & Support'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Contact Support'),
                  leading: const Icon(Icons.contact_support),
                  onTap: () {
                    // Handle contact support
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('FAQs'),
                  leading: const Icon(Icons.question_answer),
                  onTap: () {
                    // Navigate to FAQs screen
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Terms of Service'),
                  leading: const Icon(Icons.description),
                  onTap: () {
                    // Show terms of service
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(Icons.privacy_tip),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}