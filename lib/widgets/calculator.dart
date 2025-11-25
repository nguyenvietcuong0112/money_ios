
import 'package:flutter/material.dart';

class Calculator extends StatelessWidget {
  final Color cardColor;
  final Color textColor;

  const Calculator({
    super.key,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          ...['C', '', '%', '/'],
          ...['7', '8', '9', 'x'],
          ...['4', '5', '6', '-'],
          ...['1', '2', '3', '+'],
          ...['.', '0', '=', 'OK'],
        ].map((key) {
          return ElevatedButton(
            onPressed: () { /* Calculator logic goes here */ },
            child: Text(key, style: const TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
