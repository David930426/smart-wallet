import 'package:flutter/material.dart';
// REMOVE: import '../helpers/db_helper.dart'; // Old helper
// REMOVE: import '../models/income.dart';   // Old model
// REMOVE: import '../models/expense.dart';  // Old model
import '../database/database.dart'; // The new unified helper
import '../models/transaction.dart'; // The new unified model
import 'package:intl/intl.dart';

class AddTransaction extends StatefulWidget {
  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Income'; // default type for the Dropdown
  DateTime _selectedDate = DateTime.now();

  Future<void> _saveTransaction() async {
  if (!_formKey.currentState!.validate()) return;

  final title = _titleController.text;
  final amount = double.tryParse(_amountController.text) ?? 0.0;
  final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

  // 1. Determine the unified TransactionType
  final transactionType = _type == 'Income' 
      ? TransactionType.income 
      : TransactionType.expense;

  // 2. Create the unified Transaction object
  final newTransaction = Transaction(
    title: title,
    amount: amount,
    date: dateStr,
    type: transactionType,
  );

  try {
    // 3. Call the single insert method on the correct helper class
    // Assuming your unified database class is named DatabaseHelper
    await DatabaseHelper().insertTransaction(newTransaction);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction saved successfully!')),
      );
    }

    // Pop with true to indicate success
    Navigator.pop(context, true);
  } catch (e) {
    // Log and show error message
    print('DATABASE INSERTION ERROR: $e'); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving transaction: $e')),
      );
    }
  }
}

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type selector (Dropdown)
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Income', 'Expense']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 16),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter title' : null,
              ),
              SizedBox(height: 16),

              // Amount input
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                // Only allow numbers and decimal point
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null)
                    return 'Enter a valid number';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date picker
              Row(
                children: [
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  ),
                  TextButton(onPressed: _pickDate, child: Text('Select Date')),
                ],
              ),
              SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}