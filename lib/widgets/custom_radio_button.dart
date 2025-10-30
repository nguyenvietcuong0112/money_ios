import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final bool isSelected;
  const CustomRadioButton({Key? key, required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade400,
          width: 2.0,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                ),
              ),
            )
          : null,
    );
  }
}
