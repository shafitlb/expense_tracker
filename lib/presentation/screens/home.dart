import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/presentation/screens/addExpense.dart';
import 'package:personal_expense_tracker/presentation/screens/expenseList.dart';



class Home extends StatelessWidget {
  const Home({super.key});
 
  

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      
      body: const SafeArea(
        child: ExpenseList()
        ), 
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpense()),
            );
            },
            child: const Icon(Icons.add)
            ),
    );
  }
} 