import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:money_manager/common/text_styles.dart';
import 'package:money_manager/controllers/wallet_controller.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIconPath = 'assets/icons/ic_saving.svg';

  final List<String> _iconPaths = [
    'assets/icons/ic_saving.svg',
    'assets/icons/ic_cash.svg',
    'assets/icons/ic_bank.svg',
    'assets/icons/ic_credit.svg',
    'assets/icons/ic_insurance.svg',
    'assets/icons/ic_investment.svg',
    'assets/icons/ic_loan.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_wallet'.tr, style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text;
                Get.find<WalletController>()
                    .addWallet(name, 0.0, _selectedIconPath);
                Get.back();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'wallet_name'.tr,
                  labelStyle: AppTextStyles.body,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_wallet_name'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Text('icon'.tr, style: AppTextStyles.title),
              const SizedBox(height: 16.0),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _iconPaths.length,
                  itemBuilder: (context, index) {
                    final iconPath = _iconPaths[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIconPath = iconPath;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIconPath == iconPath
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _selectedIconPath == iconPath
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(iconPath, color: _selectedIconPath == iconPath ? Colors.green : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
