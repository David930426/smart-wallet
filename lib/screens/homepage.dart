import 'package:flutter/material.dart';
import '../screens/addtransaction.dart';
import '../helpers/db_helper.dart';
import '../models/income.dart';
import '../models/expense.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Income>> _incomeList;
  late Future<List<Expense>> _expenseList;
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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


    double totalIncome = incomes.fold(0, (sum, item) => sum + item.amount);
    double totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);

    if (mounted) {
      setState(() {
        _balance = totalIncome - totalExpense;
      });
    }
  }

  // Refresh data - use setState to trigger rebuild
  void _refreshData() {
    setState(() {
      _incomeList = DBHelper().getAllIncomes();
      _expenseList = DBHelper().getAllExpenses();
    });
    _calculateBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Wallet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Balance: \$${_balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
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

                    if (incomes.isEmpty && expenses.isEmpty) {
                      return Center(child: Text('No transactions yet'));
                    }

                    return ListView(
                      children: [
                        if (incomes.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text("Incomes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          ...incomes.map((income) => ListTile(
                                title: Text(income.title),
                                subtitle: Text(income.date),
                                trailing: Text('\$${income.amount.toStringAsFixed(2)}'),
                              )),
                        ],
                        if (expenses.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text("Expenses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          ...expenses.map((expense) => ListTile(
                                title: Text(expense.title),
                                subtitle: Text(expense.date),
                                trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                              )),
                        ],
                      ],
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
          );
          
          // Only refresh if transaction was saved successfully
          if (result == true) {
            _refreshData();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}