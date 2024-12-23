import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/db/expense/expense_db.dart';
import 'package:personal_expense_tracker/domain/models/expense_model.dart';

class AddExpense extends StatefulWidget {
  final ExpenseModel? expense;
  const AddExpense({super.key, this.expense});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
  if (widget.expense != null) {
    _amountController.text = widget.expense!.amount;
    _descriptionController.text = widget.expense!.description;
    _selectedDate = DateTime.parse(widget.expense!.date);
  }
  super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String amount = _amountController.text;
      String description = _descriptionController.text;
      String date = _selectedDate != null
          ? "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}"
          : "No Date Selected";

       final updatedExpense = ExpenseModel(
      id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      description: description,
      date: date,
    );

    if (widget.expense == null) {
      // Add new expense
      ExpenseDB().insertExpense(updatedExpense);
    } else {
      // Update existing expense
      ExpenseDB().updateExpense(updatedExpense);
    }
    
      

       Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.expense == null
            ? 'Expense Added!'
            : 'Expense Updated!'),
      ),
    );
  }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Expense'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                    TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                readOnly: true,
                onTap: _presentDatePicker,
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: _selectedDate == null
                      ? 'Select Date'
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a brief description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _submitForm,
               child: Text(widget.expense == null ? 'Submit' : 'Update'),
              ),
                ],
              ),
            )));
  }
}
