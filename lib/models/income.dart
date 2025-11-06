// Path: lib/models/income.dart

class Income {
  // SQLite typically uses integer primary keys
  final int? id; 
  final String title;
  final double amount;
  final String date; // Storing date as a String (ISO 8601 format) for simplicity

  Income({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  // Convert an Income object into a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
    };
  }

  // Extract an Income object from a Map (THIS WAS MISSING)
  static Income fromMap(Map<String, dynamic> map) {
    return Income(
      // SQLite stores INTEGER primary keys as int, but nullable int? is safe
      id: map['id'] as int?, 
      title: map['title'] as String,
      // SQLite stores REAL as double
      amount: map['amount'] as double,
      date: map['date'] as String,
    );
  }

  @override
  String toString() {
    return 'Income{id: $id, title: $title, amount: $amount, date: $date}';
  }
}