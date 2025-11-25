
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/screens/to_currency_screen.dart';
import 'package:money_manager/services/exchange_rate_service.dart';
import 'package:money_manager/widgets/calculator.dart';
import 'package:money_manager/widgets/from_currency_card.dart';
import 'package:money_manager/widgets/to_currency_list.dart';

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  _ExchangeRateScreenState createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final _amountController = TextEditingController(text: '1');
  final _exchangeRateService = ExchangeRateService();

  Currency _fromCurrency = CurrencyService().findByCode('IDR')!;
  final List<Currency> _toCurrencies = [
    CurrencyService().findByCode('USD')!,
    CurrencyService().findByCode('RUB')!,
  ];
  Map<String, double> _rates = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final rates = await _exchangeRateService.fetchExchangeRates(_fromCurrency.code);
      setState(() {
        _rates = rates;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      Get.snackbar(
        'Error',
        _errorMessage!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFromCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          _fromCurrency = currency;
          _fetchRates();
        });
      },
    );
  }

  void _navigateAndAddToCurrency() async {
    final selectedCurrencies = await Get.to<List<Currency>>(() => ToCurrencyScreen(selectedCurrencies: _toCurrencies));

    if (selectedCurrencies != null) {
      setState(() {
        _toCurrencies.clear();
        _toCurrencies.addAll(selectedCurrencies);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('convert_money'.tr, style: AppTextStyles.title.copyWith(color: AppColors.textColorBlack)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textColorBlack,
      ),
      body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    FromCurrencyCard(
                      fromCurrency: _fromCurrency,
                      amountController: _amountController,
                      openFromCurrencyPicker: _openFromCurrencyPicker,
                      primaryColor: AppColors.primaryColor,
                      cardColor: AppColors.cardColor,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ToCurrencyList(
                        isLoading: _isLoading,
                        toCurrencies: _toCurrencies,
                        rates: _rates,
                        amount: double.tryParse(_amountController.text) ?? 0,
                        navigateAndAddCurrency: _navigateAndAddToCurrency,
                        primaryColor: AppColors.primaryColor,
                        cardColor: AppColors.cardColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * (2 / 5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Calculator(
                  cardColor: AppColors.cardColor,
                  textColor: AppColors.textColorBlack,
                  onValueChanged: (value) {
                    setState(() {
                      _amountController.text = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
    );
  }
}
