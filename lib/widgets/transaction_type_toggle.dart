import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_manager/models/transaction_model.dart';

class TransactionTypeToggle extends StatefulWidget {
  final Function(TransactionType) onChanged;

  const TransactionTypeToggle({
    super.key,
    required this.onChanged,
  });

  @override
  State<TransactionTypeToggle> createState() => _TransactionTypeToggleState();
}

class _TransactionTypeToggleState extends State<TransactionTypeToggle> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          _buildButton(TransactionType.expense),
          _buildButton(TransactionType.income),
        ],
      ),
    );
  }

  Widget _buildButton(TransactionType type) {
    final isSelected = _selectedType == type;
    final color = type == TransactionType.expense ? Colors.red : Colors.green;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
          widget.onChanged(type);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                type == TransactionType.expense
                    ? 'assets/icons/ic_expense.svg'
                    : 'assets/icons/ic_income.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : Colors.black54,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                type == TransactionType.expense ? 'EXPENSE' : 'INCOME',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
