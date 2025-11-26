import 'package:flutter/material.dart';
import '../screens/addtransaction.dart';
import '../database/database.dart';
import '../models/transaction.dart'; // Use the unified model

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use a single Future for the combined list
  late Future<List<Transaction>> _transactionList; 
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Refresh data by fetching ALL transactions
  void _refreshData() async {
    // 1. Fetch all transactions from the single table
    final transactions = await DatabaseHelper().getAllTransactions();
    double currentBalance = 0.0;

    // 2. Calculate balance locally from the combined list
    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        currentBalance += t.amount;
      } else {
        currentBalance -= t.amount;
      }
    }
    // The list is already sorted by date DESC in getAllTransactions
    
    setState(() {
      _transactionList = Future.value(transactions);
      _balance = currentBalance;
    });
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _balance >= 0 ? Colors.green : Colors.red),
            ),
          ),
          // Separator
          Divider(),
          
          // Single FutureBuilder for ALL transactions
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: _transactionList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransaction()),
          ).then((_) => _refreshData()); // Refresh when returning from AddTransaction
        },
        child: Icon(Icons.add),
      ),
    );
  }
}