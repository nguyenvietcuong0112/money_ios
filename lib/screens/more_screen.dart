import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/screens/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: const Text(
          'More Tools',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54, size: 28),
            onPressed: () {
              // Navigate to the original settings screen
              Get.to(() => const SettingsScreen());
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildToolCard(
              context,
              title: 'Exchange Rate',
              subtitle: 'Fast currency conversion calculator',
              iconData: Icons.currency_exchange,
              color: Colors.orange,
              onTap: () {
                // TODO: Get.to(() => ExchangeRateScreen());
                 Get.snackbar('Coming Soon', 'Exchange Rate feature is under development.');
              },
            ),
            const SizedBox(height: 16),
            // Placeholder for the ad banner
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const Center(
                child: Text(
                  'Ad Banner Placeholder',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              title: 'Personal Loan',
              subtitle: 'Quick personal interest calculation',
              iconData: Icons.real_estate_agent,
              color: Colors.pink,
              onTap: () {
                // TODO: Get.to(() => PersonalLoanScreen());
                Get.snackbar('Coming Soon', 'Personal Loan feature is under development.');
              },
            ),
            const SizedBox(height: 16),
             _buildToolCard(
              context,
              title: 'Credit Card',
              subtitle: 'Calculate your card repayments',
              iconData: Icons.credit_card,
              color: Colors.red,
              onTap: () {
                 Get.snackbar('Coming Soon', 'Credit Card feature is under development.');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {required String title, required String subtitle, required IconData iconData, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(iconData, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 16),
          ],
        ),
      ),
    );
  }
}
