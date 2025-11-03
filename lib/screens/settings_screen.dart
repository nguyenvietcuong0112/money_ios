import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/theme_controller.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/screens/currency_selection_screen.dart';
import 'package:money_manager/screens/language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (localizations == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Settings', style: AppTextStyles.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings') ?? 'Settings', style: AppTextStyles.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                GetX<ThemeController>(
                  builder: (themeController) => SwitchListTile(
                    title: Text(localizations.translate('dark_mode') ?? 'Dark Mode', style: AppTextStyles.body),
                    value: themeController.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeController.toggleTheme();
                    },
                    secondary: const Icon(Icons.palette),
                  ),
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, 'General'),
          Card(
            child: GetX<AppController>(
              builder: (appController) => Column(
                children: [
                  ListTile(
                    title: Text(localizations.translate('language') ?? 'Language', style: AppTextStyles.body),
                    trailing: Text(appController.locale?.languageCode ?? '', style: AppTextStyles.body.copyWith(color: Colors.grey)),
                    leading: const Icon(Icons.language),
                    onTap: () {
                      Get.to(() => const LanguageSelectionScreen());
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(localizations.translate('currency') ?? 'Currency', style: AppTextStyles.body),
                    trailing: Text(appController.currencySymbol, style: AppTextStyles.body.copyWith(color: Colors.grey)),
                    leading: const Icon(Icons.monetization_on),
                    onTap: () {
                      Get.to(() => const CurrencySelectionScreen());
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildSectionTitle(context, 'Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Enable Notifications', style: AppTextStyles.body),
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
                  title: Text('Set Passcode', style: AppTextStyles.body),
                  leading: const Icon(Icons.lock),
                  onTap: () {
                    // Navigate to passcode screen
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: Text('Enable Fingerprint', style: AppTextStyles.body),
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
                  title: Text('Contact Support', style: AppTextStyles.body),
                  leading: const Icon(Icons.contact_support),
                  onTap: () {
                    // Handle contact support
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text('FAQs', style: AppTextStyles.body),
                  leading: const Icon(Icons.question_answer),
                  onTap: () {
                    // Navigate to FAQs screen
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text('Terms of Service', style: AppTextStyles.body),
                  leading: const Icon(Icons.description),
                  onTap: () {
                    // Show terms of service
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text('Privacy Policy', style: AppTextStyles.body),
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
        style: AppTextStyles.title,
      ),
    );
  }
}
