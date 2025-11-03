import 'package:flutter/material.dart';
import 'package:money_manager/common/text_styles.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget', style: AppTextStyles.title),
      ),
      body: Center(
        child: Text('Budget Screen', style: AppTextStyles.body),
      ),
    );
  }
}
