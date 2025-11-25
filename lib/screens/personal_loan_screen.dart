
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/screens/personal_loan_result_screen.dart';
import 'package:money_manager/widgets/loan_action_buttons.dart';
import 'package:money_manager/widgets/loan_date_picker.dart';
import 'package:money_manager/widgets/loan_input_field.dart';
import 'package:money_manager/widgets/loan_term_field.dart';

class PersonalLoanScreen extends StatefulWidget {
  const PersonalLoanScreen({super.key});

  @override
  State<PersonalLoanScreen> createState() => _PersonalLoanScreenState();
}

class _PersonalLoanScreenState extends State<PersonalLoanScreen> {
  final _loanAmountController = TextEditingController();
  final _processingFeeController = TextEditingController();
  final _termYearsController = TextEditingController();
  final _termMonthsController = TextEditingController();
  DateTime _startDate = DateTime.now();

  void _calculateAndNavigate() {
    final double? loanAmount = double.tryParse(_loanAmountController.text);
    final double? processingFee = double.tryParse(_processingFeeController.text);
    final int? years = int.tryParse(_termYearsController.text);
    final int? months = int.tryParse(_termMonthsController.text);

    final int termInMonths = (years ?? 0) * 12 + (months ?? 0);

    if (loanAmount == null ||
        loanAmount <= 0 ||
        processingFee == null ||
        processingFee < 0 ||
        termInMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_enter_valid_loan_details'.tr)),
      );
      return;
    }

    // This is a placeholder for a real interest rate calculation
    final double annualRate = 5.0;
    double monthlyPayment;
    double totalPayment;
    double totalInterest;

    final double monthlyRate = annualRate / 12 / 100;

    if (annualRate > 0) {
      monthlyPayment = loanAmount *
          (monthlyRate * pow(1 + monthlyRate, termInMonths)) /
          (pow(1 + monthlyRate, termInMonths) - 1);
    } else {
      monthlyPayment = loanAmount / termInMonths;
    }

    totalPayment = monthlyPayment * termInMonths;
    totalInterest = totalPayment - loanAmount;

    DateTime payOffDate =
        DateTime(_startDate.year, _startDate.month + termInMonths, _startDate.day);

    Get.to(() => PersonalLoanResultScreen(
          loanAmount: loanAmount,
          interestRate: annualRate,
          loanTermInYears: termInMonths / 12.0,
          startDate: _startDate,
          monthlyPayment: monthlyPayment,
          totalInterest: totalInterest,
          totalPayment: totalPayment,
          payOffDate: payOffDate,
        ));
  }

  void _resetFields() {
    _loanAmountController.clear();
    _processingFeeController.clear();
    _termYearsController.clear();
    _termMonthsController.clear();
    setState(() {
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('personal_loan'.tr, style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.fieldColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoanInputField(
                label: 'loan_amount'.tr,
                controller: _loanAmountController,
                suffixText: '₹',
                backgroundColor: AppColors.backgroundColor,
              ),
              const SizedBox(height: 16),
              LoanInputField(
                label: 'processing_fee'.tr,
                controller: _processingFeeController,
                suffixText: '%',
                backgroundColor: AppColors.backgroundColor,
              ),
              const SizedBox(height: 24),
              LoanTermField(
                yearsController: _termYearsController,
                monthsController: _termMonthsController,
                backgroundColor: AppColors.backgroundColor,
              ),
              const SizedBox(height: 24),
              LoanDatePicker(
                selectedDate: _startDate,
                selectDate: _selectStartDate,
                backgroundColor: AppColors.backgroundColor,
                primaryColor: AppColors.primaryColor,
              ),
              const SizedBox(height: 32),
              LoanActionButtons(
                onCalculate: _calculateAndNavigate,
                onReset: _resetFields,
                primaryColor: AppColors.primaryColor,
                secondaryButtonColor: AppColors.secondaryButtonColor,
                buttonTextColor: AppColors.buttonTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
