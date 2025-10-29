
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/providers/app_provider.dart';

enum TransactionType { expense, income, loan }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  TransactionType _selectedType = TransactionType.expense;
  double? _amount;
  String? _selectedCategory;
  String? _budget;
  String? _lender;
  String? _note;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // --- Category Lists ---
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'icon': Icons.fastfood},
    {'name': 'Beauty', 'icon': Icons.spa},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Travel', 'icon': Icons.airplanemode_active},
    {'name': 'Health', 'icon': Icons.favorite},
    {'name': 'Charity', 'icon': Icons.volunteer_activism},
    {'name': 'Bills', 'icon': Icons.receipt},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Family', 'icon': Icons.group},
    {'name': 'Home Services', 'icon': Icons.home_repair_service},
    {'name': 'Invest', 'icon': Icons.trending_up},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.payment},
    {'name': 'Business', 'icon': Icons.business},
    {'name': 'Gift', 'icon': Icons.card_giftcard},
    {'name': 'Loan', 'icon': Icons.real_estate_agent},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedType = TransactionType.values[_tabController.index];
        _selectedCategory = null; // Reset category on tab change
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- UI Building Methods ---

  Widget _buildAmountField(String currencySymbol) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: currencySymbol,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter an amount';
        if (double.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
      onSaved: (value) => _amount = double.parse(value!),
    );
  }

  Widget _buildCategorySelector() {
    List<Map<String, dynamic>> currentCategories = _selectedType == TransactionType.expense 
        ? _expenseCategories 
        : _incomeCategories;
    
    if (_selectedType == TransactionType.loan) {
       _selectedCategory = 'Loan';
        return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Loan'),
        );
    }

    return InkWell(
      onTap: () => _showCategoryDialog(currentCategories),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: _selectedCategory == null
            ? const Text('Choose Category')
            : Text(_selectedCategory!),
      ),
    );
  }

  Widget _buildBudgetField() {
    if (_selectedType != TransactionType.expense) return const SizedBox.shrink();
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Budget',
            hintText: 'None',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.arrow_drop_down)
          ),
          onSaved: (value) => _budget = value,
        ),
      ],
    );
  }
  
  Widget _buildLenderField() {
      if (_selectedType != TransactionType.loan) return const SizedBox.shrink();
      return Column(
          children: [
              const SizedBox(height: 16),
              TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Lender',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                      if (_selectedType == TransactionType.loan && (value == null || value.isEmpty)) {
                          return 'Please enter a lender name';
                      }
                      return null;
                  },
                  onSaved: (value) => _lender = value,
              ),
          ],
      );
  }

  Widget _buildDateTimeField() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(DateFormat.yMd().format(_selectedDate)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                 suffixIcon: const Icon(Icons.access_time),
              ),
              child: Text(_selectedTime.format(context)),
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildNoteField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Note',
        hintText: 'Add a description...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
       maxLength: 100,
      onSaved: (value) => _note = value,
    );
  }

  // --- Logic Methods ---

  void _showCategoryDialog(List<Map<String, dynamic>> categories) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['name'];
                  });
                  Navigator.of(context).pop();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(category['icon'], color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 5),
                    Text(category['name'], style: const TextStyle(fontSize: 12), textAlign: TextAlign.center,),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) setState(() => _selectedTime = picked);
  }

 void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a category')),
        );
        return;
    }

    _formKey.currentState!.save();

    double finalAmount = _amount!;
    bool isExpense = true;

    switch (_selectedType) {
      case TransactionType.expense:
        finalAmount = -_amount!;
        isExpense = true;
        break;
      case TransactionType.income:
        isExpense = false;
        break;
      case TransactionType.loan:
        isExpense = false; // Loans are considered income initially
        break;
    }

    final newTransaction = TransactionModel(
      id: DateTime.now().toString(),
      title: _selectedCategory!, // Or a different title if needed
      amount: finalAmount,
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute),
      category: _selectedCategory!,
      note: _note,
      isExpense: isExpense,
      budget: _selectedType == TransactionType.expense ? _budget : null,
      lender: _selectedType == TransactionType.loan ? _lender : null,
    );

    Provider.of<AppProvider>(context, listen: false).addTransaction(newTransaction);
    Navigator.of(context).pop();
}


  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppProvider>(context).currencySymbol;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Add Transaction'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Type Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedType == TransactionType.expense 
                          ? Colors.red
                          : _selectedType == TransactionType.income
                            ? Colors.green
                            : Colors.blue,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Expense'),
                    Tab(text: 'Income'),
                    Tab(text: 'Loan'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Form Fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountField(currency),
                      const SizedBox(height: 16),
                      _buildCategorySelector(),
                       _buildBudgetField(),
                       _buildLenderField(),
                      const SizedBox(height: 16),
                      _buildDateTimeField(),
                      const SizedBox(height: 16),
                      _buildNoteField(),
                    ],
                  ),
                ),
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blue.shade700,
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
