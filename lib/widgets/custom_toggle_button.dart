import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';

class CustomToggleButton extends StatelessWidget {
  final bool isMonthSelected;
  final VoidCallback onMonthSelected;
  final VoidCallback onYearSelected;

  const CustomToggleButton({
    super.key,
    required this.isMonthSelected,
    required this.onMonthSelected,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isMonthSelected ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onMonthSelected,
                  child: Center(
                    child: Text(
                      'month'.tr,
                      style: AppTextStyles.button.copyWith(
                        color: isMonthSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onYearSelected,
                  child: Center(
                    child: Text(
                      'year'.tr,
                      style: AppTextStyles.button.copyWith(
                        color: !isMonthSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
