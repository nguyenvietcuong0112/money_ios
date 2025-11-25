
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/common/text_styles.dart';

class LoanDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback selectDate;
  final Color backgroundColor;
  final Color primaryColor;

  const LoanDatePicker({
    super.key,
    required this.selectedDate,
    required this.selectDate,
    required this.backgroundColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('start_date'.tr,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: AppTextStyles.body,
                ),
                Icon(Icons.calendar_today, color: primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
