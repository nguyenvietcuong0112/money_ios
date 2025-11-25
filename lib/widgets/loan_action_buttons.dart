
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';

class LoanActionButtons extends StatelessWidget {
  final VoidCallback onCalculate;
  final VoidCallback onReset;
  final Color primaryColor;
  final Color secondaryButtonColor;
  final Color buttonTextColor;

  const LoanActionButtons({
    super.key,
    required this.onCalculate,
    required this.onReset,
    required this.primaryColor,
    required this.secondaryButtonColor,
    required this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCalculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text('calculate'.tr,
                style: AppTextStyles.button.copyWith(color: buttonTextColor)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryButtonColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text('reset_fields'.tr,
                style: AppTextStyles.button.copyWith(color: Colors.black87)),
          ),
        ),
      ],
    );
  }
}
