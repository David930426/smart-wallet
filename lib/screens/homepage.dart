import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_store.dart';
import 'transaction.dart';
import 'addtransaction.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final transactions = TransactionStore().getAll();
    final balance = TransactionStore().getBalance();

    return Scaffold(
      appBar: AppBar(title: Text('Smart Wallet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Balance: \$${balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text('No transactions yet'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (_, index) {
                      final t = transactions[index];
                      return ListTile(
                        leading: Icon(
                          t.type == TransactionType.income
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: t.type == TransactionType.income
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(t.title),
                        subtitle: Text(t.date),
                        trailing: Text(
                          (t.type == TransactionType.income ? '+' : '-') +
                              '\$${t.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: t.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransaction()),
          );
          _refresh(); // refresh after returning
        },
      ),
    );
  }
}
