import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double amount;

  BudgetModel({required this.category, required this.amount});
}
