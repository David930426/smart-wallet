// Imports: Note the 'as sql' prefix to avoid conflict with the Transaction model
import 'package:sqflite/sqflite.dart' as sql; 
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static sql.Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, 'wallet.db');
    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(sql.Database db, int version) async {
    // Creating ONE unified table called 'transactions'
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        type INTEGER  /* 1=income, 0=expense */
      )
    ''');
  }

  // Insert a new transaction (income or expense)
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Retrieve all transactions
  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    // Query the single table, ordered by date
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC'); 
    
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }
  
  // Method to calculate the total balance
  Future<double> getBalance() async {
    final transactions = await getAllTransactions();
    double totalBalance = 0.0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        totalBalance += t.amount;
      } else { // expense
        totalBalance -= t.amount;
      }
    }
    return totalBalance;
  }
}