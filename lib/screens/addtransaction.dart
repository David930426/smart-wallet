import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_store.dart';
import 'transaction.dart';

class AddTransaction extends StatefulWidget {
  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Income';
  DateTime _selectedDate = DateTime.now();

  void _save() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final type = _type == 'Income' ? TransactionType.income : TransactionType.expense;

    TransactionStore().add(Transaction(
      title: title,
      amount: amount,
      date: dateStr,
      type: type,
    ));

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: ['Income', 'Expense'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) { if (val != null) setState(() => _type = val); },
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextFormField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
            TextFormField(controller: _amountController, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
            Row(
              children: [
                Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                TextButton(onPressed: _pickDate, child: Text('Select Date')),
              ],
            ),
            ElevatedButton(onPressed: _save, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
