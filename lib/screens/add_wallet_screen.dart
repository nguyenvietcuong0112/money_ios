import 'package:flutter/material.dart';
import 'package:money_manager/localization/app_localizations.dart';
import 'package:money_manager/providers/wallet_provider.dart';
import 'package:provider/provider.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  IconData _selectedIcon = Icons.account_balance_wallet;

  final List<IconData> _icons = [
    Icons.account_balance_wallet,
    Icons.credit_card,
    Icons.account_balance,
    Icons.money,
    Icons.sports_esports,
    Icons.camera_alt,
    Icons.shopping_cart,
    Icons.train,
    Icons.lightbulb_outline,
    Icons.local_hospital,
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('add_wallet') ?? 'Add Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text;
                final amount = double.parse(_amountController.text);
                Provider.of<WalletProvider>(context, listen: false).addWallet(name, amount, _selectedIcon);
                Navigator.pop(context);
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
                decoration: const InputDecoration(
                  labelText: 'Wallet Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a wallet name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Initial Amount',
                  border: OutlineInputBorder(),
                  suffixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Text('Icon', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16.0),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon ? Colors.green.withAlpha(70) : Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _selectedIcon == icon ? Colors.green : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(icon, size: 30, color: _selectedIcon == icon ? Colors.green : Colors.black),
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
