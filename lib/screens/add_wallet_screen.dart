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
  String _selectedIconPath = 'assets/icons/ic_food.png';

  // This list should be populated with your actual icon assets
  final List<String> _iconPaths = [
    'assets/icons/ic_food.png',
    // Add more icon paths here as you add them to your assets
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
                Provider.of<WalletProvider>(context, listen: false)
                    .addWallet(name, 0.0, _selectedIconPath);
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
                              ? Colors.green.withAlpha(70)
                              : Colors.grey.withAlpha(30),
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
                          child: Image.asset(iconPath),
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
