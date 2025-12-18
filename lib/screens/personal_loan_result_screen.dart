
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/common/text_styles.dart';

class PersonalLoanResultScreen extends StatelessWidget {
  final double loanAmount;
  final double interestRate;
  final double loanTermInYears;
  final DateTime startDate;
  final double monthlyPayment;
  final double totalInterest;
  final double totalPayment;
  final DateTime payOffDate;

  const PersonalLoanResultScreen({
    super.key,
    required this.loanAmount,
    required this.interestRate,
    required this.loanTermInYears,
    required this.startDate,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayment,
    required this.payOffDate,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_GB', symbol: '\$');
    final numberFormat = NumberFormat("#,##0.00", "en_US");
    final dateFormat = DateFormat.yMMMd();

    final int years = loanTermInYears.floor();
    final int months = ((loanTermInYears - years) * 12).round();
    final String loanTermFormatted =
        '${years > 0 ? '$years years ' : ''}${months > 0 ? '$months months' : ''}'.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: Text('personal_loan'.tr, style: AppTextStyles.title.copyWith(color: AppColors.textDefault)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Information'.tr,
              style: AppTextStyles.title.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              children: [
                _buildInfoRow('Loan Amount'.tr, '${numberFormat.format(loanAmount)} \$'),
                _buildInfoRow('Interest Rate'.tr, '${interestRate.toStringAsFixed(1)} %'),
                _buildInfoRow('Loan Term'.tr, loanTermFormatted),
                _buildInfoRow('Start Date'.tr, dateFormat.format(startDate)),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Result Calculator'.tr,
              style: AppTextStyles.title.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              children: [
                _buildInfoRow('Monthly Payment'.tr, currencyFormat.format(monthlyPayment), isHighlighted: true),
                _buildInfoRow('Total Interest'.tr, currencyFormat.format(totalInterest)),
                _buildInfoRow('Total Cost Loan Interest'.tr, currencyFormat.format(totalPayment)),
                _buildInfoRow('Pay Off Date'.tr, dateFormat.format(payOffDate)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  side:  BorderSide(color: AppColors.textColorBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text('Back to home'.tr, style: AppTextStyles.button.copyWith(color: AppColors.textColorBlue)),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body.copyWith(color: Colors.black54)),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: isHighlighted ? const Color(0xFF4CAF50) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
