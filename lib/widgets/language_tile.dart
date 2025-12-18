import 'package:flutter/material.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/widgets/custom_radio_button.dart';

class LanguageTile extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textDefault: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          // border: Border.all(
          //   color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          //   width: isSelected ? 2.0 : 1.0,
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                icon,
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body,
              ),
            ),
            CustomRadioButton(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
