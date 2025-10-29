class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? note;
  final bool isExpense;
  final String? lender; // Added for loans
  final String? budget;   // Added for expenses

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    required this.isExpense,
    this.lender,
    this.budget,
  });
}
