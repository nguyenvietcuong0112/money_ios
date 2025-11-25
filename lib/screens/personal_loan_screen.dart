
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/screens/personal_loan_result_screen.dart';

class PersonalLoanScreen extends StatefulWidget {
  const PersonalLoanScreen({super.key});

  @override
  State<PersonalLoanScreen> createState() => _PersonalLoanScreenState();
}

class _PersonalLoanScreenState extends State<PersonalLoanScreen> {
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();

  double _loanTermInYears = 0;
  DateTime _startDate = DateTime.now();

  final Color _primaryColor = const Color(0xFF4CAF50); // Neutral Green
  final Color _backgroundColor = const Color(0xFFF0F3FA);

  void _calculateAndNavigate() {
    final double? loanAmount = double.tryParse(_loanAmountController.text);
    final double? annualRate = double.tryParse(_interestRateController.text);
    final int termInMonths = (_loanTermInYears * 12).round();

    if (loanAmount == null || loanAmount <= 0 || annualRate == null || annualRate < 0 || termInMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_enter_valid_loan_details'.tr)),
      );
      return;
    }

    double monthlyPayment;
    double totalPayment;
    double totalInterest;
    
    final double monthlyRate = annualRate / 12 / 100;

    if (annualRate > 0) {
      monthlyPayment = loanAmount * (monthlyRate * pow(1 + monthlyRate, termInMonths)) / (pow(1 + monthlyRate, termInMonths) - 1);
    } else {
      monthlyPayment = loanAmount / termInMonths;
    }

    totalPayment = monthlyPayment * termInMonths;
    totalInterest = totalPayment - loanAmount;

    DateTime payOffDate = DateTime(_startDate.year, _startDate.month + termInMonths, _startDate.day);

    Get.to(() => PersonalLoanResultScreen(
      loanAmount: loanAmount,
      interestRate: annualRate,
      loanTermInYears: _loanTermInYears,
      startDate: _startDate,
      monthlyPayment: monthlyPayment,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      payOffDate: payOffDate,
    ));
  }

  void _resetFields() {
    _loanAmountController.clear();
    _interestRateController.clear();
    setState(() {
      _loanTermInYears = 0;
      _startDate = DateTime.now();
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int termInMonths = (_loanTermInYears * 12).round();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('personal_loan'.tr, style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              label: 'loan_amount'.tr,
              controller: _loanAmountController,
              suffixText: '\$',
            ),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'interest_rate'.tr,
              controller: _interestRateController,
              suffixText: '%',
            ),
            const SizedBox(height: 24),
            _buildLoanTermSlider(termInMonths),
            const SizedBox(height: 24),
            _buildDatePicker(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String suffixText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '0',
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoanTermSlider(int termInMonths) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('loan_term'.tr, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$termInMonths months', style: AppTextStyles.body.copyWith(color: _primaryColor, fontWeight: FontWeight.bold)),
                    Text('$termInMonths installments', style: AppTextStyles.body.copyWith(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          _loanTermInYears = max(0, _loanTermInYears - 1/12);
                        });
                      },
                    ),
                    Expanded(
                      child: Slider(
                        value: _loanTermInYears,
                        min: 0,
                        max: 30,
                        divisions: 360,
                        label: _loanTermInYears.toStringAsFixed(1),
                        activeColor: _primaryColor,
                        onChanged: (double value) {
                          setState(() {
                            _loanTermInYears = value;
                          });
                        },
                      ),
                    ),
                     IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                         setState(() {
                          _loanTermInYears = min(30, _loanTermInYears + 1/12);
                        });
                      },
                    ),
                  ],
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text('${_loanTermInYears.floor()} years', style: AppTextStyles.body.copyWith(color: Colors.black54)),
                     Text('30 years', style: AppTextStyles.body.copyWith(color: Colors.black54)),
                  ],
                )
              ],
            ),
          )
        ],
      );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('start_date'.tr, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMd().format(_startDate),
                  style: AppTextStyles.body,
                ),
                Icon(Icons.calendar_today, color: _primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _calculateAndNavigate,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text('calculate'.tr, style: AppTextStyles.button),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetFields,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text('reset_fields'.tr, style: AppTextStyles.button.copyWith(color: _primaryColor)),
          ),
        ),
      ],
    );
  }
}
