import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 1. UPDATE IMPORTS: Use the unified Transaction model
import '../database/database.dart'; // Ensure you use the correct file name
import '../models/transaction.dart'; 

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
    // Safely parse the amount, defaulting to 0.0 if invalid
    final amount = double.tryParse(_amountController.text) ?? 0.0; 
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Determine the TransactionType enum based on the selected dropdown value
    final transactionType = _type == 'Income' 
        ? TransactionType.income 
        : TransactionType.expense;

    // 2. CREATE UNIFIED TRANSACTION OBJECT
    final newTransaction = Transaction(
      title: title,
      amount: amount,
      date: dateStr,
      type: transactionType,
    );

    // 3. CALL SINGLE DATABASE INSERT METHOD
    // Assuming your DatabaseHelper now has an insertTransaction(Transaction t) method
    await DatabaseHelper().insertTransaction(newTransaction);
    
    // Check if insertion was successful (optional, but good practice)
    // if (id > 0) {
    //   print("Transaction inserted with ID: $id");
    // }

    Navigator.pop(context); // Go back to HomePage
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
                items: ['Income', 'Expense'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
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
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date picker
              Row(
                children: [
                  Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                  TextButton(onPressed: _pickDate, child: Text('Select Date'))
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