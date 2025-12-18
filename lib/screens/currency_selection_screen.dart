import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/color.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/app_controller.dart';
import 'package:money_manager/screens/my_home_page.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final bool isInitialSetup;

  const CurrencySelectionScreen({super.key, this.isInitialSetup = false});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  final List<Currency> _allCurrencies = CurrencyService().getAll();
  late List<Currency> _filteredCurrencies;
  final TextEditingController _searchController = TextEditingController();
  Currency? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = _allCurrencies;
    final appController = Get.find<AppController>();
    if (appController.currency.isNotEmpty) {
      try {
        _selectedCurrency = _allCurrencies.firstWhere((c) => c.code == appController.currency);
      } catch (e) {
        _selectedCurrency = null;
      }
    }
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCurrencies);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = _allCurrencies.where((c) {
        return c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onConfirm() {
    if (_selectedCurrency != null) {
      final AppController appController = Get.find();
      appController.setCurrency(_selectedCurrency!.code, _selectedCurrency!.symbol);
      if (widget.isInitialSetup) {
        Get.offAll(() => const MyHomePage());
      } else {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.colorHeader,
        title: Row(
          children: [
            Text('select_currency'.tr, style: AppTextStyles.title.copyWith(color: Colors.white)),
          ],
        ), // Dịch
        automaticallyImplyLeading: !widget.isInitialSetup,
        actions: [
          TextButton(
            onPressed: _selectedCurrency == null ? null : _onConfirm,
            child: Text(
              'next'.tr, // Dịch
              style: AppTextStyles.button.copyWith(
                color: _selectedCurrency != null
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'search'.tr, // Dịch
                labelStyle: AppTextStyles.body,
                hintText: 'search_by_currency'.tr, // Dịch
                hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final isSelected = _selectedCurrency?.code == currency.code;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6), // 👈 spacing giữa các item
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FB), // background giống ảnh
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    // /// Flag
                    // leading: CircleAvatar(
                    //   radius: 22,
                    //   backgroundImage: AssetImage(currency.flag!),
                    //   // ví dụ: assets/flags/us.png
                    // ),

                    /// Currency code
                    title: Text(
                      currency.code,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    /// Currency name
                    subtitle: Text(
                      currency.name,
                      style: AppTextStyles.caption,
                    ),

                    /// Radio chọn
                    trailing: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textColorRed
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textColorRed,
                          ),
                        ),
                      )
                          : null,
                    ),

                    onTap: () {
                      setState(() {
                        _selectedCurrency = currency;
                      });
                    },
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }
}
