import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_expense_tracker/domain/models/expense_model.dart';
import 'package:intl/intl.dart';

const EXPENSE_DB_NAME = 'expense-database';
 DateTime? _startDate;
  DateTime? _endDate;
abstract class ExpenseDbFunction {
  Future <List<ExpenseModel>> getExpenses();
  Future <void> insertExpense(ExpenseModel value);
  Future<void> deleteExpense(String expenseId);
  Future<void> updateExpense(ExpenseModel updatedExpense);
}

class ExpenseDB implements ExpenseDbFunction {
  ExpenseDB._internal();
  static ExpenseDB instance = ExpenseDB._internal();

  factory ExpenseDB() {
    return instance;
  }
  
  ValueNotifier<List<ExpenseModel>> expenseList = ValueNotifier([]); 

  @override
  Future <List<ExpenseModel>> getExpenses() async {
   final _expenseDB = await Hive.openBox<ExpenseModel>(EXPENSE_DB_NAME);
    // return _expenseDB.values.toList();
    final expenses = _expenseDB.values.toList();
  return expenses;
  }

  @override
  Future<void> insertExpense(ExpenseModel value) async {
    final _expenseDB = await Hive.openBox<ExpenseModel>(EXPENSE_DB_NAME);
   
    await _expenseDB.put(value.id ,value);
    refreshUI();
  }

  Future<void> refreshUI() async {
    final _allExpenses = await getExpenses();
   if (_startDate != null && _endDate != null) {
    _allExpenses.removeWhere((expense) {
      final expenseDate = DateFormat('yyyy-MM-dd').parse(expense.date);
      return expenseDate.isBefore(_startDate!) || expenseDate.isAfter(_endDate!);
    });
  }
    expenseList.value = _allExpenses; // Update the entire list
  expenseList.notifyListeners();
  }
  
  @override
  Future<void> deleteExpense(String expenseId) async {
    final _expenseDB = await Hive.openBox<ExpenseModel>(EXPENSE_DB_NAME);
    await _expenseDB.delete(expenseId);
    refreshUI();

  }
  
  @override
  Future<void> updateExpense(ExpenseModel updatedExpense) async {
  final _expenseDB = await Hive.openBox<ExpenseModel>(EXPENSE_DB_NAME);
  await _expenseDB.put(updatedExpense.id, updatedExpense);
  refreshUI();
}
  
}