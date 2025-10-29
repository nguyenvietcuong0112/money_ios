class Transaction {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String? note;
  final String? budget;
  final String? lender;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
    this.budget,
    this.lender,
  });
}
