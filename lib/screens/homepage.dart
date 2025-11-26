import 'package:flutter/material.dart';
import '../screens/addtransaction.dart';
import '../database/database.dart';
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
    _refreshData();
  }

  // Refresh both income, expense, and balance
  void _refreshData() async {
    final incomes = await DatabaseHelper().getAllIncome();
    final expenses = await DatabaseHelper().getAllExpense();

    double totalIncome = incomes.fold(0, (sum, item) => sum + item.amount);
    double totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);

    setState(() {
      _incomeList = Future.value(incomes);
      _expenseList = Future.value(expenses);
      _balance = totalIncome - totalExpense;
    });
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
                if (!incomeSnapshot.hasData) return Center(child: CircularProgressIndicator());
                final incomes = incomeSnapshot.data!;
                return FutureBuilder<List<Expense>>(
                  future: _expenseList,
                  builder: (context, expenseSnapshot) {
                    if (!expenseSnapshot.hasData) return Center(child: CircularProgressIndicator());
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransaction()),
          ).then((_) => _refreshData());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
