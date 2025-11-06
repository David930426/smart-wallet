// Path: lib/database/database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart'; // Import ini diperlukan untuk WidgetsFlutterBinding.ensureInitialized()

// Asumsi model Income terletak di sini, seperti yang diimpor di widget Anda.
// Anda mungkin perlu menyesuaikan path ini jika letaknya berbeda.
import '../models/income.dart'; 

class DatabaseHelper {
  // 1. Singleton (Pola Desain)
  // Memastikan hanya ada satu instance dari DatabaseHelper yang digunakan di seluruh aplikasi.
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // 2. Referensi Database
  static Database? _database;

  // 3. Getter untuk inisialisasi database jika belum ada
  Future<Database> get database async {
    // Memastikan binding Flutter sudah diinisialisasi
    WidgetsFlutterBinding.ensureInitialized();
    if (_database != null) return _database!;
    
    // Jika _database null, panggil _initDatabase
    _database = await _initDatabase();
    return _database!;
  }

  // 4. Inisialisasi dan buka database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'smart_wallet.db');

    // Buka database atau buat jika belum ada
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 5. Membuat tabel database (dipanggil hanya sekali saat pertama kali dibuka)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE incomes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT
      )
    ''');
    debugPrint('Database table "incomes" created.');
  }

  // --- Metode yang Digunakan oleh Widget Anda ---

  // Metode untuk Menyimpan Pemasukan Baru (Digunakan oleh AddTransaction)
  Future<int> insertIncome(Income income) async {
    final db = await database;
    try {
      final id = await db.insert(
        'incomes',
        income.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Income inserted with ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error inserting income: $e');
      rethrow;
    }
  }

  // Metode untuk Mengambil Semua Pemasukan (Digunakan oleh HomePage)
  Future<List<Income>> getAllIncome() async {
    final db = await database;
    
    // Query untuk mendapatkan semua baris dari tabel 'incomes', diurutkan berdasarkan tanggal
    final List<Map<String, dynamic>> maps = await db.query('incomes', orderBy: 'id DESC');

    // Konversi List<Map<String, dynamic>> menjadi List<Income>.
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

  // --- Metode Tambahan (Opsional) ---

  // Contoh metode untuk menutup database
  Future<void> closeDb() async {
    final db = await database;
    db.close();
    _database = null;
  }
}