
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/services/exchange_rate_service.dart';
import 'package:money_manager/common/utils.dart'; // For flag emoji

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  _ExchangeRateScreenState createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final _amountController = TextEditingController();
  final _resultController = TextEditingController();
  final _exchangeRateService = ExchangeRateService();

  late Currency _fromCurrency;
  late Currency _toCurrency;
  Map<String, double> _rates = {};
  bool _isLoading = false;
  String? _errorMessage;

  final Color _primaryColor = const Color(0xFF8BC34A);
  final Color _secondaryColor = const Color(0xFF4CAF50);
  final Color _backgroundColor = const Color(0xFFF0F4F0);

  @override
  void initState() {
    super.initState();
    // Set default currencies from the package
    _fromCurrency = CurrencyService().findByCode('GBP')!;
    _toCurrency = CurrencyService().findByCode('USD')!;
    _amountController.text = '1';
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
        _calculateExchange();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _resultController.text = 'Error';
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

  void _calculateExchange() {
    if (_rates.isEmpty) return;
    final double amount = double.tryParse(_amountController.text) ?? 0;
    final double toRate = _rates[_toCurrency.code] ?? 0.0;
    final double result = amount * toRate;
    setState(() {
      _resultController.text = result.toStringAsFixed(2);
    });
  }

  void _swapCurrencies() {
    setState(() {
      final tempCurrency = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tempCurrency;
      _fetchRates();
    });
  }

  void _resetFields() {
    setState(() {
      _fromCurrency = CurrencyService().findByCode('GBP')!;
      _toCurrency = CurrencyService().findByCode('USD')!;
      _amountController.text = '1';
      _fetchRates();
    });
  }

  void _openCurrencyPicker(bool isFrom) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          if (isFrom) {
            _fromCurrency = currency;
            _fetchRates(); // Fetch new rates when 'from' currency changes
          } else {
            _toCurrency = currency;
            _calculateExchange(); // Recalculate when 'to' currency changes
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('exchange_rate'.tr, style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildCurrencyInput(
                  controller: _amountController,
                  selectedCurrency: _fromCurrency,
                  onTap: () => _openCurrencyPicker(true),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(Icons.swap_vert, size: 32, color: _secondaryColor),
                  onPressed: _swapCurrencies,
                ),
                const SizedBox(height: 20),
                 _buildCurrencyInput(
                  controller: _resultController,
                  selectedCurrency: _toCurrency,
                  onTap: () => _openCurrencyPicker(false),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _calculateExchange,
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
                    child: Text('reset'.tr, style: AppTextStyles.button.copyWith(color: _primaryColor)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput({
    required TextEditingController controller,
    required Currency selectedCurrency,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.body.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: AppTextStyles.body.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              onChanged: (_) => _calculateExchange(),
            ),
          ),
          const SizedBox(height: 40, child: VerticalDivider(color: Colors.grey, thickness: 1)),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Text(Utils.currencyToEmoji(selectedCurrency), style: AppTextStyles.body.copyWith(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${selectedCurrency.code} - ${selectedCurrency.symbol}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
