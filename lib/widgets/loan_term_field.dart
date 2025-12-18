
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';

class LoanTermField extends StatelessWidget {
  final TextEditingController yearsController;
  final TextEditingController monthsController;
  final Color backgroundColor;

  const LoanTermField({
    super.key,
    required this.yearsController,
    required this.monthsController,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Term'.tr,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: yearsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: backgroundColor,
                  hintText: 'Years',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Color(0XFFCBD4EA),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // viền khi không focus
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                    const BorderSide(color: Color(0XFFCBD4EA), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // viền khi focus
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                    const BorderSide(color: Color(0XFFCBD4EA), width: 2.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: monthsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: backgroundColor,
                    hintText: 'Months',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Color(0XFFCBD4EA),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      // viền khi không focus
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                      const BorderSide(color: Color(0XFFCBD4EA), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // viền khi focus
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                      const BorderSide(color: Color(0XFFCBD4EA), width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
