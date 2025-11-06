import 'package:flutter/material.dart';
import '../screens/addtransaction.dart';
import '../database/database.dart';
import '../models/income.dart';

class HomePage extends StatefulWidget {
  // tidak pakai const
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Income>> _incomeList;

  @override
  void initState() {
    super.initState();
    _refreshIncome();
  }

  void _refreshIncome() {
    setState(() {
      _incomeList = DatabaseHelper().getAllIncome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Wallet')),
      body: FutureBuilder<List<Income>>(
        future: _incomeList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text('No income yet'));
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final income = snapshot.data![index];
              return ListTile(
                title: Text(income.title),
                subtitle: Text(income.date),
                trailing: Text('\$${income.amount.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransaction()),
          ).then((_) => _refreshIncome());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
