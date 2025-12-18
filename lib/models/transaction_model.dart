import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

@HiveType(typeId: 3)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title; // This will now be used for the user's note.

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final String iconPath;

  @HiveField(6)
  final int colorValue;

  @HiveField(7)
  final String walletId;

  @HiveField(8) // New Field
  final String categoryName;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.iconPath,
    required this.colorValue,
    required this.walletId,
    required this.categoryName, // Add to constructor
  });

  // To make updates easier, let's add a copyWith method.
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? iconPath,
    int? colorValue,
    String? walletId,
    String? categoryName,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      colorValue: colorValue ?? this.colorValue,
      walletId: walletId ?? this.walletId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
