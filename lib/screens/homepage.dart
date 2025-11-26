import 'package:flutter/material.dart';
import '../screens/addtransaction.dart';
<<<<<<< HEAD
import '../database/database.dart';
import '../models/transaction.dart'; // Use the unified model
=======
import '../helpers/db_helper.dart';
import '../models/income.dart';
import '../models/expense.dart';
>>>>>>> origin/jovi

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use a single Future for the combined list
  Future<List<Transaction>> _transactionList = Future.value([]);
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

<<<<<<< HEAD
  // Refresh data by fetching ALL transactions
  void _refreshData() async {
    // 1. Fetch all transactions from the single table
    final transactions = await DatabaseHelper().getAllTransactions();
    double currentBalance = 0.0;
=======
  // Initial load - NO setState here
  void _loadData() {
    _incomeList = DBHelper().getAllIncomes();
    _expenseList = DBHelper().getAllExpenses();
    _calculateBalance();
  }

  // Calculate balance
  Future<void> _calculateBalance() async {
    final incomes = await DBHelper().getAllIncomes();
    final expenses = await DBHelper().getAllExpenses();

>>>>>>> origin/jovi

    // 2. Calculate balance locally from the combined list
    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        currentBalance += t.amount;
      } else {
        currentBalance -= t.amount;
      }
    }
    // The list is already sorted by date DESC in getAllTransactions

    if (mounted) {
      setState(() {
        _balance = totalIncome - totalExpense;
      });
    }
  }

  // Refresh data - use setState to trigger rebuild
  void _refreshData() {
    setState(() {
<<<<<<< HEAD
      _transactionList = Future.value(transactions);
      _balance = currentBalance;
=======
      _incomeList = DBHelper().getAllIncomes();
      _expenseList = DBHelper().getAllExpenses();
>>>>>>> origin/jovi
    });
    _calculateBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Wallet')),
      body: Column(
        children: [
          // Display the Balance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Balance: \$${_balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
          // Separator
          Divider(),

          // Single FutureBuilder for ALL transactions
          Expanded(
<<<<<<< HEAD
            child: FutureBuilder<List<Transaction>>(
              future: _transactionList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No transactions yet'));
                }
=======
            child: FutureBuilder<List<Income>>(
              future: _incomeList,
              builder: (context, incomeSnapshot) {
                if (incomeSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!incomeSnapshot.hasData) {
                  return Center(child: Text('No data available'));
                }
                
                final incomes = incomeSnapshot.data!;
                
                return FutureBuilder<List<Expense>>(
                  future: _expenseList,
                  builder: (context, expenseSnapshot) {
                    if (expenseSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!expenseSnapshot.hasData) {
                      return Center(child: Text('No data available'));
                    }
                    
                    final expenses = expenseSnapshot.data!;
>>>>>>> origin/jovi

                final transactions = snapshot.data!;

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isIncome = transaction.type == TransactionType.income;
                    final color = isIncome ? Colors.green : Colors.red;
                    final sign = isIncome ? '+' : '-';

                    return ListTile(
                      title: Text(transaction.title),
                      subtitle: Text(transaction.date),
                      trailing: Text(
                        '$sign\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransaction()),
<<<<<<< HEAD
          ).then(
            (_) => _refreshData(),
          ); // Refresh when returning from AddTransaction
=======
          );
          
          // Only refresh if transaction was saved successfully
          if (result == true) {
            _refreshData();
          }
>>>>>>> origin/jovi
        },
        child: Icon(Icons.add),
      ),
    );
  }
}