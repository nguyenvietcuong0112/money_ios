import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/controllers/theme_controller.dart';
import 'package:money_manager/screens/currency_selection_screen.dart';
import 'package:money_manager/screens/language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr, style: AppTextStyles.title), // Dịch
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'appearance'.tr), // Dịch
          Card(
            child: Column(
              children: [
                GetX<ThemeController>(
                  builder: (themeController) => SwitchListTile(
                    title: Text('dark_mode'.tr, style: AppTextStyles.body), // Dịch
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
          _buildSectionTitle(context, 'general'.tr), // Dịch
          Card(
            child: GetX<AppController>(
              builder: (appController) => Column(
                children: [
                  ListTile(
                    title: Text('language'.tr, style: AppTextStyles.body), // Dịch
                    trailing: Text(appController.locale?.languageCode ?? '', style: AppTextStyles.body.copyWith(color: Colors.grey)),
                    leading: const Icon(Icons.language),
                    onTap: () {
                      Get.to(() => const LanguageSelectionScreen());
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('currency'.tr, style: AppTextStyles.body), // Dịch
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
          _buildSectionTitle(context, 'notifications'.tr), // Dịch
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('enable_notifications'.tr, style: AppTextStyles.body), // Dịch
                  value: false, // Replace with actual value
                  onChanged: (value) {
                    // Handle notification setting change
                  },
                  secondary: const Icon(Icons.notifications),
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, 'security'.tr), // Dịch
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('set_passcode'.tr, style: AppTextStyles.body), // Dịch
                  leading: const Icon(Icons.lock),
                  onTap: () {
                    // Navigate to passcode screen
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: Text('enable_fingerprint'.tr, style: AppTextStyles.body), // Dịch
                  value: false, // Replace with actual value
                  onChanged: (value) {
                    // Handle fingerprint setting change
                  },
                  secondary: const Icon(Icons.fingerprint),
                ),
              ],
            ),
          ),
          _buildSectionTitle(context, 'help_and_support'.tr), // Dịch
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('contact_support'.tr, style: AppTextStyles.body), // Dịch
                  leading: const Icon(Icons.contact_support),
                  onTap: () {
                    // Handle contact support
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text('faqs'.tr, style: AppTextStyles.body), // Dịch
                  leading: const Icon(Icons.question_answer),
                  onTap: () {
                    // Navigate to FAQs screen
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text('terms_of_service'.tr, style: AppTextStyles.body), // Dịch
                  leading: const Icon(Icons.description),
                  onTap: () {
                    // Show terms of service
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text('privacy_policy'.tr, style: AppTextStyles.body), // Dịch
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
