
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/common/utils.dart';

class FromCurrencyCard extends StatelessWidget {
  final Currency fromCurrency;
  final TextEditingController amountController;
  final VoidCallback openFromCurrencyPicker;
  final Color primaryColor;
  final Color cardColor;

  const FromCurrencyCard({
    super.key,
    required this.fromCurrency,
    required this.amountController,
    required this.openFromCurrencyPicker,
    required this.primaryColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: openFromCurrencyPicker,
            child: Row(
              children: [
                Text(Utils.currencyToEmoji(fromCurrency), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fromCurrency.code, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    Text(fromCurrency.name, style: AppTextStyles.body.copyWith(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.title.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
