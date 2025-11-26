import 'package:flutter/material.dart';
import '../screens/addtransaction.dart';

// Assuming your unified database helper is in '../database/database.dart'
// If your helper is named DBHelper, it must be the unified one.
import '../database/database.dart'; 
import '../models/transaction.dart'; // Must use the unified Transaction model

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Single source of truth for the list, initialized to prevent crashes
  Future<List<Transaction>> _transactionList = Future.value([]); 
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Start loading data immediately
  }

  // Unified function to fetch data, calculate balance, and update UI
  void _refreshData() async {
    // 2. Fetch all transactions using the unified method
    // (Assuming DatabaseHelper is your unified database class)
    final transactions = await DatabaseHelper().getAllTransactions();
    double currentBalance = 0.0;
    
    // 3. Calculate balance locally
    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        currentBalance += t.amount;
      } else { // expense
        currentBalance -= t.amount;
      }
    }
    
    // The list is already sorted by date DESC in getAllTransactions
    if (mounted) {
      setState(() {
        // 4. Update the single list and balance
        _transactionList = Future.value(transactions);
        _balance = currentBalance;
      });
    }
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
          Divider(),

          // 5. Single FutureBuilder for ALL transactions
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: _transactionList, // Use the single list variable
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                // Check if data is present and the list isn't empty
                if (!snapshot.hasData || snapshot.data!.isEmpty) { 
                  return Center(child: Text('No transactions yet'));
                }

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
          // Await the navigation result (we expect 'true' if saved successfully)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransaction()),
          );
          
          // Only refresh if the AddTransaction screen returned 'true'
          if (result == true) { 
            _refreshData();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}