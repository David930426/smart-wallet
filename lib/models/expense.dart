class Expense {
  final int? id;
  final String title;
  final double amount;
  final String date;

  Expense({this.id, required this.title, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
    };
  }
}
