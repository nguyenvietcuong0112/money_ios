import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';

class LoanInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffixText;
  final Color backgroundColor;

  const LoanInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.suffixText,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor,
            hintText: '0',
            suffixText: suffixText,
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
      ],
    );
  }
}
