
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/common/utils.dart';

class ToCurrencyList extends StatelessWidget {
  final bool isLoading;
  final List<Currency> toCurrencies;
  final Map<String, double> rates;
  final double amount;
  final VoidCallback navigateAndAddCurrency;
  final Color primaryColor;
  final Color cardColor;

  const ToCurrencyList({
    super.key,
    required this.isLoading,
    required this.toCurrencies,
    required this.rates,
    required this.amount,
    required this.navigateAndAddCurrency,
    required this.primaryColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: toCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = toCurrencies[index];
                        final rate = rates[currency.code] ?? 0.0;
                        final result = amount * rate;
                        return ListTile(
                          leading: Text(Utils.currencyToEmoji(currency), style: const TextStyle(fontSize: 24)),
                          title: Text(currency.code, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text('1:${rate.toStringAsFixed(4)}', style: AppTextStyles.body.copyWith(color: Colors.grey)),
                          trailing: Text(result.toStringAsFixed(2), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: navigateAndAddCurrency,
              icon: const Icon(Icons.add),
              label: Text('add'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
