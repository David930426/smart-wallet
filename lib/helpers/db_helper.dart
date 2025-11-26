import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/income.dart';
import '../models/expense.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'smart_wallet.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE incomes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Income CRUD
  Future<void> insertIncome(Income income) async {
    final db = await database;
    await db.insert('incomes', income.toMap());
  }

  // Future<void> insertIncome(Income income) async {
  //   final db = await database;
  //   await db.insert('incomes', income.toMap());
  //   print('DEBUG DBHelper: Inserted income - ${income.toString()}');
  // }

  Future<List<Income>> getAllIncomes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('incomes');
    return List.generate(maps.length, (i) => Income.fromMap(maps[i]));
  }

  // Future<List<Income>> getAllIncomes() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query('incomes');
  //   print('DEBUG DBHelper: Retrieved ${maps.length} incomes from database');
  //   return List.generate(maps.length, (i) {
  //     final income = Income.fromMap(maps[i]);
  //     print('DEBUG DBHelper: Income ${i + 1} - ${income.toString()}');
  //     return income;
  //   });
  // }

  // Expense CRUD
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert('expenses', expense.toMap());
  }

  // Future<void> insertExpense(Expense expense) async {
  //   final db = await database;
  //   await db.insert('expenses', expense.toMap());
  //   print('DEBUG DBHelper: Inserted expense - ${expense.toString()}');
  // }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Future<List<Expense>> getAllExpenses() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query('expenses');
  //   print('DEBUG DBHelper: Retrieved ${maps.length} expenses from database');
  //   return List.generate(maps.length, (i) {
  //     final expense = Expense.fromMap(maps[i]);
  //     print('DEBUG DBHelper: Expense ${i + 1} - ${expense.toString()}');
  //     return expense;
  //   });
  // }

  // Saldo
  Future<double> getBalance() async {
    final incomes = await getAllIncomes();
    final expenses = await getAllExpenses();
    double totalIncome = incomes.fold(0, (sum, item) => sum + item.amount);
    double totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);
    return totalIncome - totalExpense;
  }
}
