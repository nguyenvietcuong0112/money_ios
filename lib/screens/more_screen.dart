
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/screens/exchange_rate_screen.dart';
import 'package:money_manager/screens/personal_loan_screen.dart';
import 'package:money_manager/screens/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FA),
      appBar: AppBar(
        title: Text(
          'more'.tr,
          style: AppTextStyles.title.copyWith(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildToolCard(
              context,
              title: 'exchange_rate'.tr,
              iconData: "assets/icons/ic_converter_money.svg",
              onTap: () {
                Get.to(() => const ExchangeRateScreen());
              },
            ),
            SizedBox(height: 10.h),
            _buildToolCard(
              context,
              title: 'personal_loan'.tr,
              iconData: "assets/icons/personal_loan.svg",
              onTap: () {
                Get.to(() => const PersonalLoanScreen());
              },
            ),
            SizedBox(height: 10.h),
            _buildToolCard(
              context,
              title: 'settings'.tr,
              iconData: "assets/icons/ic_settings.svg",
              onTap: () {
                Get.to(() => const SettingsScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {required String title, required String iconData, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(iconData, width: 40,height: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(color: Colors.black),
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
