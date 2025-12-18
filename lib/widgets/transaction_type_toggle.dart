import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_manager/models/transaction_model.dart';

import '../common/color.dart';
import '../common/text_styles.dart';

class TransactionTypeToggle extends StatefulWidget {
  /// Nếu truyền giá trị này, widget hoạt động theo chế độ "controlled":
  /// - hiển thị loại do `selectedType` cung cấp
  /// - khi người dùng chọn, widget gọi onChanged, nhưng không tự setState nội bộ
  final TransactionType? selectedType;

  /// Nếu không truyền `selectedType`, widget tự quản state nội bộ, bắt đầu từ initialSelectedType
  final TransactionType initialSelectedType;

  /// Khi user chọn đổi type, gọi callback
  final ValueChanged<TransactionType> onChanged;

  /// Hiển thị amount hay không
  final bool showAmount;

  final double? incomeAmount;
  final double? expenseAmount;
  final String currencySymbol;

  const TransactionTypeToggle({
    Key? key,
    required this.onChanged,
    this.selectedType,
    this.initialSelectedType = TransactionType.expense,
    this.showAmount = false,
    this.incomeAmount,
    this.expenseAmount,
    this.currencySymbol = '\$',
  }) : super(key: key);

  @override
  State<TransactionTypeToggle> createState() => _TransactionTypeToggleState();
}

class _TransactionTypeToggleState extends State<TransactionTypeToggle> {
  // internal state used only when widget.selectedType == null
  late TransactionType _internalSelected;

  bool get _isControlled => widget.selectedType != null;

  TransactionType get _currentSelected => _isControlled ? widget.selectedType! : _internalSelected;

  @override
  void initState() {
    super.initState();
    _internalSelected = widget.initialSelectedType;
  }

  @override
  void didUpdateWidget(covariant TransactionTypeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // nếu trước đó uncontrolled và giờ vẫn uncontrolled, không cần thay;
    // nếu controlled value thay đổi từ ngoài, build sẽ đọc widget.selectedType.
    // nhưng nếu initialSelectedType thay đổi và vẫn uncontrolled, cập nhật internal.
    if (!_isControlled && oldWidget.initialSelectedType != widget.initialSelectedType) {
      _internalSelected = widget.initialSelectedType;
    }
  }

  void _onTap(TransactionType type) {
    if (_isControlled) {
      // chỉ báo cho parent; parent phải cập nhật selectedType nếu muốn thay đổi hiển thị
      widget.onChanged(type);
    } else {
      // tự quản state
      setState(() {
        _internalSelected = type;
      });
      widget.onChanged(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.showAmount ? 80 : 50,
      child: Row(
        children: [
          _buildTypeCard(
            type: TransactionType.expense,
            title: 'EXPENSE',
            amount: widget.expenseAmount,
          ),
          _buildTypeCard(
            type: TransactionType.income,
            title: 'INCOME',
            amount: widget.incomeAmount,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required TransactionType type,
    required String title,
    double? amount,
  }) {
    final isSelected = _currentSelected == type;
    final isIncome = type == TransactionType.income;

    final bgColor = isSelected
        ? (isIncome ? AppColors.textColorGreen : AppColors.textColorRed)
        : Colors.transparent;

    final textColor = isSelected ? AppColors.textColorWhite : AppColors.textColorGrey;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(type),
        child: Container(
          padding:  EdgeInsets.symmetric(vertical: 15,horizontal: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: isIncome ? const Radius.circular(0) : const Radius.circular(16),
              topRight: isIncome ? const Radius.circular(16) : const Radius.circular(0),
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                isIncome ? 'assets/icons/ic_income.svg' : 'assets/icons/ic_expense.svg',
                width: widget.showAmount ? 45 : 24,
                height: widget.showAmount ? 45 : 24,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: widget.showAmount ? MainAxisAlignment.center : MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(color: textColor),
                  ),
                  if (widget.showAmount)
                    Text(
                      '${widget.currencySymbol}${(amount ?? 0).toStringAsFixed(0)}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
